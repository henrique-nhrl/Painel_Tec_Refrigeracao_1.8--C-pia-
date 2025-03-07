import React, { useState } from 'react';
import { Lock } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { Link } from 'react-router-dom';
import toast from 'react-hot-toast';

export function ResetPassword() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/update-password`,
      });

      if (error) throw error;

      toast.success('Email de recuperação enviado! Verifique sua caixa de entrada.');
      setEmail('');
    } catch (error) {
      toast.error('Erro ao enviar email de recuperação. Verifique se o email está correto.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900">
      <div className="max-w-md w-full space-y-8 p-8 card">
        <div className="text-center">
          <Lock className="mx-auto h-12 w-12 text-blue-500" />
          <h2 className="mt-6 text-3xl font-bold">Recuperar Senha</h2>
          <p className="mt-2 text-gray-400">
            Digite seu email para receber as instruções
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleResetPassword}>
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-400 mb-1">
              Email
            </label>
            <input
              id="email"
              type="email"
              required
              className="input w-full"
              placeholder="seu@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>

          <button
            type="submit"
            className="w-full btn btn-primary"
            disabled={loading}
          >
            {loading ? 'Enviando...' : 'Enviar Email de Recuperação'}
          </button>

          <div className="text-center">
            <Link
              to="/login"
              className="text-sm text-blue-400 hover:text-blue-500"
            >
              Voltar para o login
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}