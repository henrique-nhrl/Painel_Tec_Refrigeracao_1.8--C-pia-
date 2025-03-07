import React from 'react';
import { Copy } from 'lucide-react';
import toast from 'react-hot-toast';

interface CodeGeneratorProps {
  product: {
    name: string;
    price: number;
  };
}

export function CodeGenerator({ product }: CodeGeneratorProps) {
  const sqlCode = `SELECT name, price FROM products WHERE name = '${product.name}';`;
  
  const n8nCode = JSON.stringify({
    url: "https://api.n8n.io/webhook/SUA_URL",
    method: "GET",
    headers: {
      Authorization: "Bearer SEU_TOKEN"
    },
    readers: {
      nome: "{{response.body.name}}",
      preco: "{{response.body.price}}"
    },
    saveInVariables: {
      nome: "{{nome}}",
      preco: "{{preco}}"
    }
  }, null, 2);

  const typebotMessage = `O produto ${product.name} está cadastrado com o preço de R$ ${product.price}.`;

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast.success('Código copiado!');
  };

  return (
    <div className="space-y-4 mt-4">
      <div className="space-y-2">
        <h4 className="text-sm font-medium text-gray-400">Código SQL</h4>
        <div className="flex items-start gap-2">
          <pre className="bg-gray-800 p-2 rounded-md text-sm flex-1 overflow-x-auto">
            {sqlCode}
          </pre>
          <button
            onClick={() => copyToClipboard(sqlCode)}
            className="p-2 hover:bg-gray-700 rounded-md"
          >
            <Copy size={18} />
          </button>
        </div>
      </div>

      <div className="space-y-2">
        <h4 className="text-sm font-medium text-gray-400">HTTP Request (N8N)</h4>
        <div className="flex items-start gap-2">
          <pre className="bg-gray-800 p-2 rounded-md text-sm flex-1 overflow-x-auto">
            {n8nCode}
          </pre>
          <button
            onClick={() => copyToClipboard(n8nCode)}
            className="p-2 hover:bg-gray-700 rounded-md"
          >
            <Copy size={18} />
          </button>
        </div>
      </div>

      <div className="space-y-2">
        <h4 className="text-sm font-medium text-gray-400">Mensagem Typebot</h4>
        <div className="flex items-start gap-2">
          <pre className="bg-gray-800 p-2 rounded-md text-sm flex-1 overflow-x-auto">
            {typebotMessage}
          </pre>
          <button
            onClick={() => copyToClipboard(typebotMessage)}
            className="p-2 hover:bg-gray-700 rounded-md"
          >
            <Copy size={18} />
          </button>
        </div>
      </div>
    </div>
  );
}