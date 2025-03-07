import React from 'react';
import { Book, Users, Heart, Package, Settings, HelpCircle } from 'lucide-react';

export function Manual() {
  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold">Manual do Sistema</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="card">
          <div className="flex items-center gap-3 mb-4">
            <Package className="text-primary" size={24} />
            <h2 className="text-xl font-semibold">Produtos</h2>
          </div>
          <div className="space-y-4">
            <p>
              O módulo de produtos é o coração do sistema de atendimento automático.
              Cada produto cadastrado aqui é automaticamente sincronizado com o assistente
              virtual, permitindo respostas instantâneas e precisas sobre preços e serviços.
            </p>
            <div className="bg-blue-500/10 p-4 rounded-lg">
              <h3 className="font-medium mb-2">Recursos Principais:</h3>
              <ul className="list-disc list-inside space-y-2">
                <li>Atualização em tempo real dos preços</li>
                <li>Integração automática com chatbot</li>
                <li>Organização por categorias</li>
                <li>Controle de ordem de exibição</li>
              </ul>
            </div>
            <div className="bg-green-500/10 p-4 rounded-lg">
              <h3 className="font-medium mb-2">Dica Importante:</h3>
              <p>
                Mantenha os preços sempre atualizados, pois o assistente virtual
                utiliza essas informações para gerar orçamentos automáticos 24/7.
              </p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center gap-3 mb-4">
            <Users className="text-primary" size={24} />
            <h2 className="text-xl font-semibold">Clientes e Colaboradores</h2>
          </div>
          <div className="space-y-4">
            <p>
              O cadastro de clientes e colaboradores é essencial para o programa de fidelização.
              Cada campo foi pensado para maximizar o relacionamento e garantir
              um acompanhamento eficiente.
            </p>
            <div className="space-y-4">
              <div className="border-l-4 border-primary pl-4">
                <h3 className="font-medium mb-2">Campos do Cliente:</h3>
                <ul className="space-y-2">
                  <li>
                    <span className="font-medium">Nome Completo:</span>
                    <br />Para identificação nos registros internos
                  </li>
                  <li>
                    <span className="font-medium">Nome Formal:</span>
                    <br />Utilizado nas mensagens automáticas de WhatsApp
                  </li>
                  <li>
                    <span className="font-medium">Endereço Completo:</span>
                    <br />Localização precisa do atendimento
                  </li>
                  <li>
                    <span className="font-medium">Colaboradores:</span>
                    <br />Equipe responsável pelo atendimento
                  </li>
                  <li>
                    <span className="font-medium">Anotações:</span>
                    <br />Observações importantes sobre o cliente
                  </li>
                </ul>
              </div>
            </div>
            <div className="bg-yellow-500/10 p-4 rounded-lg">
              <h3 className="font-medium mb-2">Histórico e Rastreabilidade:</h3>
              <p>
                O sistema mantém um histórico completo de todas as alterações e atendimentos,
                incluindo quais colaboradores participaram de cada serviço.
              </p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center gap-3 mb-4">
            <Heart className="text-primary" size={24} />
            <h2 className="text-xl font-semibold">Fidelização</h2>
          </div>
          <div className="space-y-4">
            <p>
              O programa de fidelização automatiza o relacionamento com clientes,
              enviando lembretes personalizados e ofertas especiais no momento certo.
            </p>
            <div className="bg-purple-500/10 p-4 rounded-lg">
              <h3 className="font-medium mb-2">Benefícios:</h3>
              <ul className="list-disc list-inside space-y-2">
                <li>Lembretes automáticos de manutenção</li>
                <li>Mensagens personalizadas de boas-vindas</li>
                <li>Descontos para serviços recorrentes</li>
                <li>Acompanhamento do histórico do cliente</li>
              </ul>
            </div>
            <div className="bg-red-500/10 p-4 rounded-lg">
              <h3 className="font-medium mb-2">Personalização:</h3>
              <p>
                Configure o nome fantasia da empresa e as mensagens serão automaticamente
                personalizadas para cada cliente.
              </p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center gap-3 mb-4">
            <Settings className="text-primary" size={24} />
            <h2 className="text-xl font-semibold">Configurações</h2>
          </div>
          <div className="space-y-4">
            <p>
              O módulo de configurações permite personalizar diversos aspectos do sistema,
              desde informações básicas até integrações avançadas.
            </p>
            <div className="space-y-4">
              <div className="bg-indigo-500/10 p-4 rounded-lg">
                <h3 className="font-medium mb-2">Recursos Disponíveis:</h3>
                <ul className="list-disc list-inside space-y-2">
                  <li>Configuração do logo da empresa</li>
                  <li>Definição do fuso horário</li>
                  <li>Personalização de mensagens</li>
                  <li>Configuração da API de suporte</li>
                  <li>Identificação para suporte técnico</li>
                </ul>
              </div>
              <div className="bg-teal-500/10 p-4 rounded-lg">
                <h3 className="font-medium mb-2">Suporte Integrado:</h3>
                <p>
                  Acesse o suporte técnico diretamente pelo sistema através da página
                  de suporte integrada, sem necessidade de abrir novas abas ou janelas.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center gap-3 mb-4">
            <HelpCircle className="text-primary" size={24} />
            <h2 className="text-xl font-semibold">Suporte</h2>
          </div>
          <div className="space-y-4">
            <p>
              O sistema oferece uma experiência integrada de suporte técnico,
              permitindo acesso rápido e eficiente à ajuda quando necessário.
            </p>
            <div className="space-y-4">
              <div className="bg-blue-500/10 p-4 rounded-lg">
                <h3 className="font-medium mb-2">Características:</h3>
                <ul className="list-disc list-inside space-y-2">
                  <li>Acesso direto ao suporte técnico</li>
                  <li>Interface integrada ao sistema</li>
                  <li>Identificação automática do cliente</li>
                  <li>Histórico de atendimentos</li>
                </ul>
              </div>
              <div className="bg-green-500/10 p-4 rounded-lg">
                <h3 className="font-medium mb-2">Como Usar:</h3>
                <p>
                  Basta acessar a página de suporte através do menu lateral para
                  ter acesso imediato ao sistema de atendimento, sem necessidade
                  de autenticação adicional.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}