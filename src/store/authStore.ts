import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { User } from '../types/database';
import { supabase } from '../lib/supabase';

interface AuthState {
  user: User | null;
  setUser: (user: User | null) => void;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
      logout: async () => {
        try {
          // First clear the local state
          set({ user: null });
          
          // Clear localStorage
          localStorage.removeItem('auth-storage');
          
          // Then sign out from Supabase
          await supabase.auth.signOut();
          
          // Force redirect to login page
          window.location.href = '/login';
        } catch (error) {
          console.error('Error during logout:', error);
          // Force logout even if there's an error
          localStorage.removeItem('auth-storage');
          window.location.href = '/login';
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ user: state.user }),
    }
  )
);

// Listener para mudanças na sessão
supabase.auth.onAuthStateChange(async (event, session) => {
  if (event === 'SIGNED_OUT') {
    useAuthStore.getState().setUser(null);
    window.location.href = '/login';
  } else if (session?.user) {
    try {
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();
      
      if (error) throw error;
      if (profile) {
        useAuthStore.getState().setUser(profile);
      }
    } catch (error) {
      console.error('Error fetching user profile:', error);
    }
  }
});