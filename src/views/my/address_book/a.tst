
// RESPONSIVE: Cambiar a móvil en pantallas pequeñas
@media (max-width: 768px) {
  .desktop-version {
    display: none;
  }

  .mobile-version {
    display: block;
  }
}
.el-button{
  padding: 1.1rem;
  font-size: 0.9rem;
  width: 100%;
}
// Estilos versión móvil con modo oscuro
.mobile-version {
  background-color: #1a1a1a;
  padding-bottom: 20px;
  min-height: 100vh;
}


 .mobile-card-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;

    .action-btn-full {
      flex: 1 1 100%;
    }

    .action-btn {
      flex: 1;
    }
  }



.mobile-list {
  padding: 10px;
  
  .list-item-card {
    background: #2a2a2a;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 10px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.5);
    border: 1px solid #3a3a3a;
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
      
      .card-title {
        font-size: 16px;
        font-weight: 600;
        color: #e0e0e0;
      }
    }
    
    .card-info {
      color: #909399;
      font-size: 13px;
      margin-bottom: 12px;
    }
    
.card-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  text-align: center;
  
  .el-button {
    flex: 1;
    min-width: calc(50% - 4px); // 50% menos la mitad del gap
    margin: 0 !important;
  }
}
  }
}

.mobile-pagination {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  background: #2a2a2a;
  margin: 10px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.5);
  border: 1px solid #3a3a3a;
  
  :deep(.el-pagination) {
    flex-wrap: wrap;
    justify-content: center;
  }
}

.dialog-footer-mobile {
  display: flex;
  gap: 10px;
  padding: 10px 0;
}

// Estilos modo oscuro para diálogos
:deep(.el-dialog) {
  background-color: #2a2a2a;
  border: 1px solid #3a3a3a;
  
  .el-dialog__header {
    background-color: #2a2a2a;
    border-bottom: 1px solid #3a3a3a;
  }
  
  .el-dialog__title {
    color: #e0e0e0;
  }
  
  .el-dialog__body {
    background-color: #2a2a2a;
    color: #e0e0e0;
  }
  
  .el-form-item__label {
    color: #e0e0e0;
  }
  
  .el-input__inner {
    background-color: #3a3a3a;
    border-color: #4a4a4a;
    color: #e0e0e0;
  }
}

:deep(.el-select) {
  .el-input__inner {
    background-color: #3a3a3a;
    border-color: #4a4a4a;
    color: #e0e0e0;
  }
}

:deep(.el-alert) {
  background-color:#2b1d1d ;
  border-color:    #412626;
  color: #f56c6c;
  margin: 15px 0 10px 0!important;
  padding-right: 5px !important;
}