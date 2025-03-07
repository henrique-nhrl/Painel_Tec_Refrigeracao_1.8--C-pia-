import React, { useState } from 'react';
import { Upload, X } from 'lucide-react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

interface FileUploadProps {
  onUpload: (url: string) => void;
  currentUrl?: string;
  maxSize?: number; // em MB
}

export function FileUpload({ onUpload, currentUrl, maxSize = 2 }: FileUploadProps) {
  const [uploading, setUploading] = useState(false);
  const [preview, setPreview] = useState(currentUrl);

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    try {
      setUploading(true);
      const file = e.target.files?.[0];
      
      if (!file) return;

      // Validar tamanho
      if (file.size > maxSize * 1024 * 1024) {
        throw new Error(`Arquivo muito grande. Máximo ${maxSize}MB`);
      }

      // Validar tipo
      if (!file.type.startsWith('image/')) {
        throw new Error('Apenas imagens são permitidas');
      }

      // Gerar nome único
      const fileExt = file.name.split('.').pop();
      const fileName = `${Math.random().toString(36).slice(2)}.${fileExt}`;
      const filePath = `${fileName}`;

      // Upload para o Supabase Storage
      const { data, error } = await supabase.storage
        .from('logos')
        .upload(filePath, file);

      if (error) throw error;

      // Gerar URL pública
      const { data: { publicUrl } } = supabase.storage
        .from('logos')
        .getPublicUrl(filePath);

      // Atualizar preview e notificar
      setPreview(publicUrl);
      onUpload(publicUrl);
      toast.success('Logo atualizado com sucesso');
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Erro ao fazer upload');
    } finally {
      setUploading(false);
    }
  };

  const handleRemove = () => {
    setPreview(undefined);
    onUpload('');
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-4">
        <label className="btn btn-secondary">
          <input
            type="file"
            className="hidden"
            accept="image/*"
            onChange={handleUpload}
            disabled={uploading}
          />
          <Upload size={18} className="mr-2" />
          {uploading ? 'Enviando...' : 'Escolher Logo'}
        </label>
        
        {preview && (
          <button
            onClick={handleRemove}
            className="btn btn-danger"
            type="button"
          >
            <X size={18} className="mr-2" />
            Remover
          </button>
        )}
      </div>

      {preview && (
        <div className="w-32 h-32 rounded-full overflow-hidden bg-white">
          <img
            src={preview}
            alt="Logo"
            className="w-full h-full object-cover"
          />
        </div>
      )}

      <p className="text-sm text-muted-foreground">
        Tamanho máximo: {maxSize}MB. Apenas imagens.
      </p>
    </div>
  );
}