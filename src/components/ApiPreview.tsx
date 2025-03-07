import React from 'react';
import { Copy } from 'lucide-react';
import toast from 'react-hot-toast';

interface ApiPreviewProps {
  method: string;
  url: string;
  apiKey: string;
  selectedColumns: string[];
}

export function ApiPreview({ method, url, apiKey, selectedColumns }: ApiPreviewProps) {
  const code = `fetch('${url}', {
  method: '${method}',
  headers: {
    'Authorization': 'Bearer ${apiKey}',
    'Content-Type': 'application/json'
  }${method !== 'GET' ? ',\n  body: JSON.stringify({\n    // dados aqui\n  })' : ''}
})
.then(response => response.json())
.then(data => {
  // Resposta contém: ${selectedColumns.join(', ')}
  console.log(data);
})
.catch(error => console.error(error));`;

  const copyToClipboard = () => {
    navigator.clipboard.writeText(code);
    toast.success('Código copiado!');
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-medium text-muted-foreground">
          Exemplo de Uso
        </h4>
        <button
          onClick={copyToClipboard}
          className="text-primary hover:text-primary/80"
        >
          <Copy size={18} />
        </button>
      </div>
      <pre className="bg-secondary/30 p-4 rounded-md text-sm overflow-x-auto">
        {code}
      </pre>
    </div>
  );
}