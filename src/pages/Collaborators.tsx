import React, { useEffect, useState } from 'react';
import { Plus, Edit, Trash2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { Collaborator } from '../types/database';
import { ConfirmDialog } from '../components/ConfirmDialog';
import toast from 'react-hot-toast';

export function Collaborators() {
  const [collaborators, setCollaborators] = useState<Collaborator[]>([]);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [collaboratorToDelete, setCollaboratorToDelete] = useState<Collaborator | null>(null);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    active: true
  });

  useEffect(() => {
    loadCollaborators();
  }, []);

  const loadCollaborators = async () => {
    try {
      const { data, error } = await supabase
        .from('collaborators')
        .select('*')
        .order('name');
      
      if (error) throw error;
      setCollaborators(data || []);
    } catch (error) {
      console.error('Erro ao carregar colaboradores:', error);
      toast.error('Erro ao carregar lista de colaboradores');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      if (editingId) {
        const { error } = await supabase
          .from('collaborators')
          .update({
            name: formData.name,
            active: formData.active
          })
          .eq('id', editingId);
        
        if (error) throw error;
        toast.success('Colaborador atualizado com sucesso');
        setEditingId(null);
      } else {
        const { error } = await supabase
          .from('collaborators')
          .insert([{
            name: formData.name,
            active: formData.active
          }]);
        
        if (error) throw error;
        toast.success('Colaborador adicionado com sucesso');
      }

      setFormData({
        name: '',
        active: true
      });
      
      loadCollaborators();
    } catch (error) {
      console.error('Erro:', error);
      toast.error('Erro ao salvar colaborador');
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (collaborator: Collaborator) => {
    setEditingId(collaborator.id);
    setFormData({
      name: collaborator.name,
      active: collaborator.active
    });
  };

  const handleDelete = async () => {
    if (!collaboratorToDelete) return;

    try {
      const { error } = await supabase
        .from('collaborators')
        .delete()
        .eq('id', collaboratorToDelete.id);
      
      if (error) throw error;
      toast.success('Colaborador removido com sucesso');
      loadCollaborators();
      setCollaboratorToDelete(null);
      setShowDeleteDialog(false);
    } catch (error) {
      console.error('Erro ao remover colaborador:', error);
      toast.error('Erro ao remover colaborador');
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Colaboradores</h1>

      <div className="card">
        <h2 className="text-xl font-semibold mb-4">
          {editingId ? 'Editar Colaborador' : 'Novo Colaborador'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-muted-foreground">
              Nome
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={formData.name}
              onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
              required
            />
          </div>

          <div>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.active}
                onChange={(e) => setFormData(prev => ({ ...prev, active: e.target.checked }))}
                className="rounded border-input"
              />
              <span className="text-sm font-medium">Ativo</span>
            </label>
          </div>

          <div className="flex gap-2">
            <button 
              type="submit" 
              className="btn btn-primary flex-1"
              disabled={loading}
            >
              {loading ? 'Salvando...' : editingId ? 'Atualizar' : 'Adicionar'} Colaborador
            </button>
            {editingId && (
              <button
                type="button"
                onClick={() => {
                  setEditingId(null);
                  setFormData({
                    name: '',
                    active: true
                  });
                }}
                className="btn btn-danger"
              >
                Cancelar
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {collaborators.map((collaborator) => (
          <div key={collaborator.id} className="card">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-semibold">{collaborator.name}</h3>
                <p className={`text-sm ${collaborator.active ? 'text-green-500' : 'text-red-500'}`}>
                  {collaborator.active ? 'Ativo' : 'Inativo'}
                </p>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => handleEdit(collaborator)}
                  className="text-primary hover:text-primary/80"
                >
                  <Edit size={18} />
                </button>
                <button
                  onClick={() => {
                    setCollaboratorToDelete(collaborator);
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
          setCollaboratorToDelete(null);
        }}
        onConfirm={handleDelete}
        title="Confirmar Exclusão"
        message="Tem certeza que deseja excluir este colaborador? Esta ação não pode ser desfeita."
        confirmText="Excluir"
        cancelText="Cancelar"
      />
    </div>
  );
}