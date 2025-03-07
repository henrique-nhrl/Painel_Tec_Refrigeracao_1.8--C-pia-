import React, { useEffect, useState } from 'react';
import { Plus, Trash2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

interface Category {
  id: string;
  name: string;
}

export function Categories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [newCategory, setNewCategory] = useState('');

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    const { data } = await supabase
      .from('categories')
      .select('*')
      .order('name');
    if (data) setCategories(data);
  };

  const addCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const { error } = await supabase
        .from('categories')
        .insert({ name: newCategory });

      if (error) throw error;

      toast.success('Categoria adicionada com sucesso');
      setNewCategory('');
      loadCategories();
    } catch (error) {
      toast.error('Erro ao adicionar categoria');
    }
  };

  const deleteCategory = async (id: string) => {
    try {
      const { error } = await supabase
        .from('categories')
        .delete()
        .eq('id', id);

      if (error) throw error;

      toast.success('Categoria excluída com sucesso');
      loadCategories();
    } catch (error) {
      toast.error('Erro ao excluir categoria');
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Categorias</h1>
      
      <form onSubmit={addCategory} className="flex gap-2">
        <input
          type="text"
          className="input flex-1"
          placeholder="Nova categoria"
          value={newCategory}
          onChange={(e) => setNewCategory(e.target.value)}
          required
        />
        <button type="submit" className="btn btn-primary flex items-center gap-2">
          <Plus size={18} />
          Adicionar
        </button>
      </form>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {categories.map((category) => (
          <div key={category.id} className="card flex justify-between items-center">
            <span className="text-lg">{category.name}</span>
            <button
              onClick={() => deleteCategory(category.id)}
              className="text-red-500 hover:text-red-600"
            >
              <Trash2 size={18} />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}