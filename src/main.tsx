import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

// Function to set initial title and favicon
const initializeApp = async () => {
  try {
    // Try to get company name from localStorage if available
    const authStorage = localStorage.getItem('auth-storage');
    if (authStorage) {
      const parsedStorage = JSON.parse(authStorage);
      if (parsedStorage?.state?.user) {
        // User is logged in, we'll let the Layout component handle the title
      } else {
        // User is not logged in, set default title
        document.title = 'Sistema Admin';
      }
    }
  } catch (error) {
    console.error('Error initializing app:', error);
    // Set default title if there's an error
    document.title = 'Sistema Admin';
  }
};

// Initialize app
initializeApp();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
);