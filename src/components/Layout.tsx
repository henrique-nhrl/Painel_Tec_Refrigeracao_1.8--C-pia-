import React, { useEffect, useState } from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import {
  LogOut,
  Package,
  Users,
  FileText,
  Settings,
  List,
  UserPlus,
  Heart,
  Menu,
  X,
  BookOpen,
  HelpCircle,
  Users as UsersIcon,
  Wrench,
  DollarSign,
} from 'lucide-react';
import { useAuthStore } from '../store/authStore';
import { supabase } from '../lib/supabase';
import { SystemSettings } from '../types/database';

export function Layout() {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();
  const location = useLocation();
  const [settings, setSettings] = useState<SystemSettings | null>(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [pageTitle, setPageTitle] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSettings();
    const path = location.pathname.split('/')[1];
    setPageTitle(getPageTitle(path));

    // Force dark mode by default
    document.documentElement.classList.add('dark');

    const handleClickOutside = (e: MouseEvent) => {
      const sidebar = document.getElementById('mobile-sidebar');
      const menuButton = document.getElementById('mobile-menu-button');
      if (
        sidebar &&
        !sidebar.contains(e.target as Node) &&
        menuButton &&
        !menuButton.contains(e.target as Node)
      ) {
        setIsMobileMenuOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [location]);

  const loadSettings = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('system_settings')
        .select('*')
        .eq('id', '1')
        .single();

      if (error) throw error;
      if (data) {
        setSettings(data);
        
        // Update document title with company name
        if (data.company_name) {
          document.title = data.company_name;
        }
        
        // Update favicon if logo_url exists
        if (data.logo_url) {
          updateFavicon(data.logo_url);
        }
      }
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateFavicon = (logoUrl: string) => {
    const link = document.querySelector("link[rel*='icon']") || document.createElement('link');
    link.type = 'image/x-icon';
    link.rel = 'shortcut icon';
    link.href = logoUrl;
    document.getElementsByTagName('head')[0].appendChild(link);
  };

  const handleLogout = async () => {
    try {
      // First clear any local state
      await logout();
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
      // Force logout even if there's an error
      localStorage.removeItem('auth-storage');
      window.location.href = '/login';
    }
  };

  const getPageTitle = (path: string) => {
    const titles: Record<string, string> = {
      services: 'Serviços',
      clients: 'Clientes',
      financial: 'Financeiro',
      loyalty: 'Fidelização',
      collaborators: 'Colaboradores',
      products: 'Produtos',
      categories: 'Categorias',
      users: 'Usuários',
      logs: 'Logs',
      settings: 'Configurações',
      manual: 'Manual',
      support: 'Suporte',
    };
    return titles[path] || 'Dashboard';
  };

  // Menu base para todos os usuários
  const baseMenuItems = [
    { path: '/services', icon: <Wrench size={24} />, text: 'Serviços' },
    { path: '/clients', icon: <UserPlus size={24} />, text: 'Clientes' },
    { path: '/financial', icon: <DollarSign size={24} />, text: 'Financeiro' },
    { path: '/loyalty', icon: <Heart size={24} />, text: 'Fidelização' },
    {
      path: '/collaborators',
      icon: <UsersIcon size={24} />,
      text: 'Colaboradores',
    },
    { path: '/settings', icon: <Settings size={24} />, text: 'Configurações' },
    { path: '/manual', icon: <BookOpen size={24} />, text: 'Manual' },
    { path: '/support', icon: <HelpCircle size={24} />, text: 'Suporte' },
  ];

  // Menu adicional para admins
  const adminMenuItems = [
    { path: '/categories', icon: <List size={24} />, text: 'Categorias' },
    { path: '/products', icon: <Package size={24} />, text: 'Produtos' },
    { path: '/users', icon: <Users size={24} />, text: 'Usuários' },
    { path: '/logs', icon: <FileText size={24} />, text: 'Logs' },
  ];

  // Combinar menus baseado no papel do usuário
  const menuItems =
    user?.role === 'admin'
      ? [...baseMenuItems, ...adminMenuItems]
      : baseMenuItems;

  return (
    <div className="min-h-screen flex bg-background">
      {/* Sidebar */}
      <aside
        id="mobile-sidebar"
        className={`
          fixed md:relative top-0 left-0 h-full w-72 bg-card shadow-lg
          transition-transform duration-300 ease-in-out z-50
          ${
            isMobileMenuOpen
              ? 'translate-x-0'
              : '-translate-x-full md:translate-x-0'
          }
          overflow-y-auto
        `}
      >
        <div className="flex flex-col h-full">
          <div className="p-4 flex items-center gap-3 border-b border-border">
            {settings?.logo_url && (
              <img
                src={settings.logo_url}
                alt="Logo"
                className="w-8 h-8 rounded-full object-cover bg-white"
              />
            )}
            <span className="text-xl font-bold">
              {settings?.company_name || 'Painel Tec'}
            </span>
            <button
              onClick={() => setIsMobileMenuOpen(false)}
              className="md:hidden text-muted-foreground hover:text-foreground ml-auto"
            >
              <X size={24} />
            </button>
          </div>

          <nav className="flex-1 px-2 py-4">
            {menuItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setIsMobileMenuOpen(false)}
                className={`
                  flex items-center gap-4 px-4 py-3 rounded-lg mb-2
                  ${
                    location.pathname === item.path
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:text-foreground hover:bg-accent'
                  }
                `}
              >
                {item.icon}
                <span className="text-sm font-medium">{item.text}</span>
              </Link>
            ))}
          </nav>

          <div className="p-4 border-t border-border">
            <button
              onClick={handleLogout}
              className="w-full flex items-center gap-4 px-4 py-3 rounded-lg text-destructive hover:bg-destructive/10"
            >
              <LogOut size={24} />
              <span className="text-sm font-medium">Sair</span>
            </button>
          </div>
        </div>
      </aside>

      {/* Main content */}
      <div className="flex-1 flex flex-col min-h-screen">
        {/* Mobile header */}
        <header className="md:hidden bg-card p-4 flex items-center justify-between border-b border-border fixed top-0 left-0 right-0 z-40">
          <button
            id="mobile-menu-button"
            onClick={() => setIsMobileMenuOpen(true)}
            className="text-muted-foreground hover:text-foreground"
          >
            <Menu size={24} />
          </button>
          <h1 className="text-xl font-bold">
            {pageTitle}
          </h1>
          <div className="w-8" />
        </header>

        {/* Content */}
        <main className="flex-1 p-4 md:p-6 bg-background mt-[60px] md:mt-0">
          <div className="max-w-[1200px] mx-auto">
            <div className="bg-card rounded-lg shadow-sm p-4 md:p-6">
              <Outlet />
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-card border-t border-border p-4 text-center">
          <p className="text-sm text-muted-foreground">
            Desenvolvido por{' '}
            <a
              href="https://henriquelr.com.br"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:text-primary/80"
            >
              henriqueLR.com.br
            </a>
            {settings?.support_id && (
              <span className="ml-2">| ID: {settings.support_id}</span>
            )}
          </p>
        </footer>
      </div>
    </div>
  );
}