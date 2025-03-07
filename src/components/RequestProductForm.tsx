import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import { useAuthStore } from '../store/authStore';
import toast from 'react-hot-toast';

interface Category {
  id: string;
  name: string;
}

interface RequestProductFormProps {
  categories: Category[];
}

export function RequestProductForm({ categories }: RequestProductFormProps) {
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [loading, setLoading] = useState(false);
  const { user } = useAuthStore();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const { error } = await supabase.from('product_requests').insert({
        user_id: user?.id,
        name,
        price: Number(price),
        description,
        category_id: categoryId
      });

      if (error) throw error;

      toast.success('Solicitação enviada com sucesso!');
      setName('');
      setPrice('');
      setDescription('');
      setCategoryId('');
    } catch (error) {
      toast.error('Erro ao enviar solicitação. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-400">
          Nome do Produto
        </label>
        <input
          type="text"
          id="name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="input w-full mt-1"
          required
          placeholder="Digite o nome do produto"
        />
      </div>

      <div>
        <label htmlFor="category" className="block text-sm font-medium text-gray-400">
          Categoria
        </label>
        <select
          id="category"
          value={categoryId}
          onChange={(e) => setCategoryId(e.target.value)}
          className="input w-full mt-1"
          required
        >
          <option value="">Selecione uma categoria</option>
          {categories.map((category) => (
            <option key={category.id} value={category.id}>
              {category.name}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label htmlFor="price" className="block text-sm font-medium text-gray-400">
          Preço Inicial
        </label>
        <input
          type="number"
          id="price"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
          className="input w-full mt-1"
          required
          step="0.01"
          min="0"
          placeholder="0,00"
        />
      </div>

      <div>
        <label htmlFor="description" className="block text-sm font-medium text-gray-400">
          Descrição
        </label>
        <textarea
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="input w-full mt-1"
          required
          rows={4}
          placeholder="Descreva o produto em detalhes"
        />
      </div>

      <div className="space-y-4">
        <button 
          type="submit" 
          className="btn btn-primary w-full"
          disabled={loading}
        >
          {loading ? 'Enviando...' : 'Enviar Solicitação'}
        </button>
        
        <a
          href="https://wa.me/5545988225939"
          target="_blank"
          rel="noopener noreferrer"
          className="btn bg-green-600 hover:bg-green-700 w-full flex items-center justify-center gap-2"
        >
          Falar com o Administrador no WhatsApp
        </a>
      </div>
    </form>
  );
}