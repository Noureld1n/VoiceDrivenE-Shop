import React from 'react';
import { AiOutlineShoppingCart, AiOutlineLaptop, AiOutlineApple, AiOutlineHome } from 'react-icons/ai';
import { api } from '../lib/client';
import styles from '../styles/categories.module.css';

// NOTE: this component only shows the category cards + "Show All Products" button.
// The product list itself is rendered once, by the home page (pages/index.js).
const Categories = ({ onCategoryClick, selectedCategoryId }) => {
  const categories = [
    {
      id: 1,
      name: 'Electronics',
      description: 'Tech & Gadgets',
      icon: <AiOutlineLaptop />,
      color: '#324d67'
    },
    {
      id: 2,
      name: 'Groceries',
      description: 'Food & Beverages',
      icon: <AiOutlineApple />,
      color: '#4CAF50'
    },
    {
      id: 3,
      name: 'Wearings',
      description: 'Fashion & Apparel',
      icon: <AiOutlineShoppingCart />,
      color: '#f02d34'
    }
  ];

  // Fetch the category's products and hand them to the parent page
  const handleCategorySelect = async (categoryId, categoryName) => {
    try {
      if (categoryId === null) {
        // Show all products (handled by parent component)
        onCategoryClick(null, 'All Products');
        return;
      }

      const response = await api.products.getByCategory(categoryId);
      console.log('Category products response:', response);

      if (response.data) {
        // Handle both array and paginated response formats
        const products = Array.isArray(response.data)
          ? response.data
          : response.data.content || [];
        onCategoryClick(categoryId, categoryName, products);
      } else {
        onCategoryClick(categoryId, categoryName, []);
      }
    } catch (error) {
      console.error('Error fetching category products:', error);
    }
  };

  return (
    <div className="categories-section">
      <div className="categories-header">
        <h2>Shop by Category</h2>
        <p>Browse our voice-enabled product categories</p>
      </div>
      <div className="categories-container">
        {categories.map((category) => (
          <div
            key={category.id}
            className={`category-card ${selectedCategoryId === category.id ? 'selected' : ''}`}
            style={{ '--category-color': category.color }}
            onClick={() => handleCategorySelect(category.id, category.name)}
          >
            <div className="category-icon">
              {category.icon}
            </div>
            <div className="category-content">
              <h3 className="category-name">{category.name}</h3>
              <p className="category-description">{category.description}</p>
              <div className="category-voice-hint">
                Say "Show me {category.name.toLowerCase()}"
              </div>
            </div>
            <div className="category-arrow">→</div>
          </div>
        ))}
      </div>
      <div className={styles['category-filter-info']}>
        <button
          className={styles['clear-filter-btn']}
          onClick={() => handleCategorySelect(null, 'All Products')}
        >
          <AiOutlineHome style={{ fontSize: '1.2rem' }} /> Show All Products
        </button>
      </div>
    </div>
  );
};

export default Categories;