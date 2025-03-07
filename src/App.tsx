import React, { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { Layout } from './components/Layout';
import { Login } from './pages/Login';
import { ResetPassword } from './pages/ResetPassword';
import { Services } from './pages/Services';
import { Products } from './pages/Products';
import { Categories } from './pages/Categories';
import { CompanySettings } from './pages/CompanySettings';
import { ProductRequests } from './pages/ProductRequests';
import { Users } from './pages/Users';
import { Logs } from './pages/Logs';
import { Clients } from './pages/Clients';
import { Financial } from './pages/Financial';
import { Loyalty } from './pages/Loyalty';
import { Manual } from './pages/Manual';
import { Collaborators } from './pages/Collaborators';
import { Support } from './pages/Support';
import { useAuthStore } from './store/authStore';
import { supabase } from './lib/supabase';

function App() {
  const { user, setUser } = useAuthStore();

  useEffect(() => {
    // Verificar sessão atual
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        supabase
          .from('profiles')
          .select('*')
          .eq('id', session.user.id)
          .single()
          .then(({ data: profile }) => {
            if (profile) {
              setUser(profile);
            }
          });
      }
    });
  }, [setUser]);

  if (!user) {
    return (
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/reset-password" element={<ResetPassword />} />
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
        <Toaster position="top-right" />
      </BrowserRouter>
    );
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/services" replace />} />
          <Route path="/services" element={<Services />} />
          <Route path="/clients" element={<Clients />} />
          <Route path="/financial" element={<Financial />} />
          <Route path="/loyalty" element={<Loyalty />} />
          <Route path="/collaborators" element={<Collaborators />} />
          <Route path="/settings" element={<CompanySettings />} />
          <Route path="/manual" element={<Manual />} />
          <Route path="/support" element={<Support />} />
          {user.role === 'admin' && (
            <>
              <Route path="/categories" element={<Categories />} />
              <Route path="/products" element={<Products />} />
              <Route path="/requests" element={<ProductRequests />} />
              <Route path="/users" element={<Users />} />
              <Route path="/logs" element={<Logs />} />
            </>
          )}
        </Route>
      </Routes>
      <Toaster position="top-right" />
    </BrowserRouter>
  );
}

export default App;