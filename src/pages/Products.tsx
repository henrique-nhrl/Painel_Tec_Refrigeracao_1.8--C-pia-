import React, { useEffect, useState } from 'react';
import { Plus, Edit, Trash2, X, Copy, Check, AlertCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Product } from '../types/database';
import { useAuthStore } from '../store/authStore';
import { RequestProductForm } from '../components/RequestProductForm';
import { ConfirmDialog } from '../components/ConfirmDialog';
import toast from 'react-hot-toast';

interface Category {
  id: string;
  name: string;
}

interface SystemSettings {
  enable_product_requests: boolean;
}

export function Products() {
  const navigate = useNavigate();
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [showRequestForm, setShowRequestForm] = useState(false);
  const [showNewProductForm, setShowNewProductForm] = useState(false);
  const [pendingRequests, setPendingRequests] = useState(0);
  const [settings, setSettings] = useState<SystemSettings>({
    enable_product_requests: true
  });
  const [newProduct, setNewProduct] = useState({ 
    name: '', 
    price: '', 
    category_id: '',
    display_order: 0 
  });
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [productToDelete, setProductToDelete] = useState<Product | null>(null);
  const { user } = useAuthStore();
  const isAdmin = user?.role === 'admin';

  useEffect(() => {
    loadProducts();
    loadCategories();
    if (isAdmin) {
      loadPendingRequests();
    }
    loadSettings();
  }, [isAdmin]);

  const loadProducts = async () => {
    const { data } = await supabase
      .from('products')
      .select(`
        *,
        categories (
          name
        )
      `)
      .order('display_order');
    if (data) setProducts(data);
  };

  const loadCategories = async () => {
    const { data } = await supabase
      .from('categories')
      .select('*')
      .order('name');
    if (data) setCategories(data);
  };

  const loadPendingRequests = async () => {
    const { count } = await supabase
      .from('product_requests')
      .select('*', { count: 'exact' })
      .eq('status', 'pending');
    setPendingRequests(count || 0);
  };

  const loadSettings = async () => {
    try {
      const { data, error } = await supabase
        .from('system_settings')
        .select('enable_product_requests')
        .eq('id', '1')
        .single();
      
      if (error) throw error;
      if (data) setSettings(data);
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
    }
  };

  const updateSettings = async (enable_product_requests: boolean) => {
    try {
      const { error } = await supabase
        .from('system_settings')
        .update({ enable_product_requests })
        .eq('id', '1');

      if (error) throw error;
      setSettings(prev => ({ ...prev, enable_product_requests }));
      toast.success('Configuração atualizada com sucesso');
    } catch (error) {
      console.error('Erro ao atualizar configuração:', error);
      toast.error('Erro ao atualizar configuração');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingProduct) {
        const { error } = await supabase
          .from('products')
          .update({
            name: newProduct.name,
            price: Number(newProduct.price),
            category_id: newProduct.category_id
          })
          .eq('id', editingProduct.id);

        if (error) throw error;
        toast.success('Produto atualizado com sucesso');
      } else {
        const { error } = await supabase
          .from('products')
          .insert({
            name: newProduct.name,
            price: Number(newProduct.price),
            category_id: newProduct.category_id,
            display_order: await getNextDisplayOrder()
          });

        if (error) throw error;
        toast.success('Produto adicionado com sucesso');
      }

      setNewProduct({ name: '', price: '', category_id: '', display_order: 0 });
      setEditingProduct(null);
      setShowNewProductForm(false);
      loadProducts();
    } catch (error) {
      toast.error('Erro ao salvar produto');
    }
  };

  const getNextDisplayOrder = async () => {
    const { data } = await supabase
      .from('products')
      .select('display_order')
      .order('display_order', { ascending: false })
      .limit(1);
    
    return data && data[0] ? data[0].display_order + 1 : 1;
  };

  const handleDelete = async () => {
    if (!productToDelete) return;

    try {
      const { error } = await supabase
        .from('products')
        .delete()
        .eq('id', productToDelete.id);

      if (error) throw error;
      toast.success('Produto removido com sucesso');
      loadProducts();
    } catch (error) {
      toast.error('Erro ao remover produto');
    } finally {
      setShowDeleteDialog(false);
      setProductToDelete(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <h1 className="text-2xl font-bold">Produtos</h1>
        <div className="flex flex-col md:flex-row gap-4 w-full md:w-auto">
          {isAdmin && (
            <>
              <button
                onClick={() => setShowNewProductForm(true)}
                className="btn btn-primary flex items-center gap-2"
              >
                <Plus size={18} />
                Novo Produto
              </button>
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground whitespace-nowrap">
                  Permitir solicitações:
                </span>
                <button
                  onClick={() => updateSettings(!settings.enable_product_requests)}
                  className={`btn ${settings.enable_product_requests ? 'btn-primary' : 'btn-secondary'}`}
                >
                  {settings.enable_product_requests ? <Check size={18} /> : <X size={18} />}
                </button>
              </div>
              {pendingRequests > 0 && (
                <button
                  onClick={() => navigate('/requests')}
                  className="btn btn-primary flex items-center gap-2"
                >
                  <AlertCircle size={18} />
                  {pendingRequests} solicitações
                </button>
              )}
            </>
          )}
          {!isAdmin && settings.enable_product_requests && (
            <button
              onClick={() => setShowRequestForm(true)}
              className="btn btn-primary flex items-center gap-2 w-full md:w-auto"
            >
              <Plus size={18} />
              Solicitar Produto
            </button>
          )}
        </div>
      </div>

      {showNewProductForm && (
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">
            {editingProduct ? 'Editar Produto' : 'Novo Produto'}
          </h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-muted-foreground">
                  Nome
                </label>
                <input
                  type="text"
                  className="input w-full mt-1"
                  value={newProduct.name}
                  onChange={(e) => setNewProduct(prev => ({ ...prev, name: e.target.value }))}
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-muted-foreground">
                  Categoria
                </label>
                <select
                  className="input w-full mt-1"
                  value={newProduct.category_id}
                  onChange={(e) => setNewProduct(prev => ({ ...prev, category_id: e.target.value }))}
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
                <label className="block text-sm font-medium text-muted-foreground">
                  Preço
                </label>
                <input
                  type="number"
                  className="input w-full mt-1"
                  value={newProduct.price}
                  onChange={(e) => setNewProduct(prev => ({ ...prev, price: e.target.value }))}
                  step="0.01"
                  min="0"
                  required
                />
              </div>
            </div>

            <div className="flex gap-2">
              <button type="submit" className="btn btn-primary flex-1">
                {editingProduct ? 'Atualizar' : 'Adicionar'} Produto
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowNewProductForm(false);
                  setEditingProduct(null);
                  setNewProduct({ name: '', price: '', category_id: '', display_order: 0 });
                }}
                className="btn btn-danger"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      )}

      {showRequestForm && (
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">Solicitar Novo Produto</h2>
          <RequestProductForm categories={categories} />
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {products.map((product) => (
          <div key={product.id} className="card">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-semibold">{product.name}</h3>
                <p className="text-muted-foreground">
                  Categoria: {product.categories?.name}
                </p>
                <p className="text-lg font-medium mt-2">
                  R$ {Number(product.price).toFixed(2)}
                </p>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setEditingProduct(product);
                    setNewProduct({
                      name: product.name,
                      price: String(product.price),
                      category_id: product.category_id,
                      display_order: product.display_order
                    });
                    setShowNewProductForm(true);
                  }}
                  className="text-primary hover:text-primary/80"
                >
                  <Edit size={18} />
                </button>
                <button
                  onClick={() => {
                    setProductToDelete(product);
                    setShowDeleteDialog(true);
                  }}
                  className="text-destructive hover:text-destructive/80"
                >
                  <Trash2 size={18} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <ConfirmDialog
        isOpen={showDeleteDialog}
        onClose={() => {
          setShowDeleteDialog(false);
          setProductToDelete(null);
        }}
        onConfirm={handleDelete}
        title="Confirmar Exclusão"
        message="Tem certeza que deseja excluir este produto? Esta ação não pode ser desfeita."
        confirmText="Excluir"
        cancelText="Cancelar"
      />
    </div>
  );
}