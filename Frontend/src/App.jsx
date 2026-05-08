import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Landing from './pages/Landing';
import Registration from './pages/Registration';
import AdminDashboard from './pages/AdminDashboard';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/"         element={<Landing />} />
        <Route path="/dang-ky"  element={<Registration />} />
        <Route path="/admin"    element={<AdminDashboard />} />
      </Routes>
    </BrowserRouter>
  );
}
