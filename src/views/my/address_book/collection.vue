<template>
  <div class="responsive-container">
    <!-- VERSIÓN ESCRITORIO (Original) -->
    <div class="desktop-version">
      <!-- Tarjeta con botones de filtro y agregar -->
      <el-card class="list-query" shadow="hover">
        <el-form inline label-width="80px">
          <el-form-item>
            <!-- Botón para agregar un nuevo registro -->
            <el-button type="primary" :icon="CirclePlusFilled" @click="toAdd">{{ T('Add Group') }}</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <!-- Tarjeta con tabla de elementos -->
      <el-card class="list-body" shadow="hover">
        <!-- Mensaje informativo -->
        <el-tag type="danger" effect="light" style="margin-bottom: 10px">{{ T('MyAddressBookTips') }}</el-tag>

        <!-- Tabla de datos -->
        <el-table :data="list" v-loading="listRes.loading" border>
          <el-table-column prop="name" :label="T('Name')" align="center"/>
          <el-table-column prop="created_at" :label="T('CreatedAt')" align="center"/>

          <!-- Columna de acciones -->
          <el-table-column :label="T('Actions')" align="center" class-name="table-actions" width="600" fixed="right">
            <template #default="{row}">
              <template v-if="row.id>0">
                <!-- Botón para editar -->
                <el-button :icon="Edit" type="warning" @click="toEdit(row)">{{ T('Edit') }}</el-button>
                <!-- Botón para eliminar -->
                <el-button :icon="DeleteFilled" type="danger" @click="del(row)">{{ T('Delete') }}</el-button>
              </template>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <!-- Paginación -->
      <el-card class="list-page" shadow="hover">
        <el-pagination background
                       layout="prev, pager, next, sizes, jumper"
                       :page-sizes="[10,20,50,100]"
                       v-model:page-size="listQuery.page_size"
                       v-model:current-page="listQuery.page"
                       :total="listRes.total">
        </el-pagination>
      </el-card>
    </div>

    <!-- VERSIÓN MÓVIL -->
    <div class="mobile-version">
      <!-- Barra de acciones superior -->
      <div class="mobile-actions">
      
        <el-button type="primary" :icon="CirclePlusFilled" @click="toAdd" class="action-btn-full">
          {{ T('Add Group') }}
        </el-button>
      </div>

      <!-- Mensaje informativo -->
      <el-alert 
        :title="T('MyAddressBookTips')" 
        type="warning" 
        :closable="false"
        style="margin: 10px;"
      />

      <!-- Lista de tarjetas -->
      <div class="mobile-list" v-loading="listRes.loading">
        <div v-for="item in list" :key="item.id" class="list-item-card">
          <div class="card-header">
            <div class="card-title">{{ item.name }}</div>
            <el-tag v-if="item.id === 0" type="primary" size="small">Default</el-tag>
          </div>
          
          <div v-if="item.created_at" class="card-info">
            <span>{{ T('CreatedAt') }}: {{ item.created_at }}</span>
          </div>

          <div v-if="item.id > 0" class="card-actions">
            <el-button :icon="Edit" type="warning"  class="action-btn"  @click="toEdit(item)">
              {{ T('Edit') }}
            </el-button>
            <el-button  :icon="DeleteFilled" type="danger" class="action-btn" @click="del(item)">
              {{ T('Delete') }}
            </el-button>
          </div>
        </div>

        <el-empty v-if="!listRes.loading && list.length === 0" description="No data" />
      </div>

      <!-- Paginación móvil -->
      <div class="mobile-pagination">
        <el-pagination
          small
          background
          layout="prev, pager, next"
          v-model:current-page="listQuery.page"
          :page-size="listQuery.page_size"
          :total="listRes.total"
        />
        <el-select v-model="listQuery.page_size" size="small" style="width: 100px; margin-top: 10px;">
          <el-option :label="`${size} / page`" :value="size" v-for="size in [10,20,50,100]" :key="size" />
        </el-select>
      </div>
    </div>

    <!-- Diálogo de creación/edición -->
    <el-dialog v-model="formVisible" width="800" :title="!formData.id?T('Create') :T('Update')" :fullscreen="isMobile">
      <el-form class="dialog-form" ref="form" :model="formData" :label-width="isMobile ? 'auto' : '120px'" :label-position="isMobile ? 'top' : 'right'">
        <el-form-item :label="T('Name')" prop="name" required>
          <el-input v-model="formData.name" :size="isMobile ? 'large' : 'default'"></el-input>
        </el-form-item>
        <el-form-item v-if="!isMobile">
          <!-- Botones de cancelar y enviar -->
          <el-button @click="formVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submit" type="primary">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
      
      <template v-if="isMobile" #footer>
        <div class="dialog-footer-mobile">
          <el-button @click="formVisible = false" size="large" style="flex: 1;">
            {{ T('Cancel') }}
          </el-button>
          <el-button @click="submit" type="primary" size="large" style="flex: 1;">
            {{ T('Submit') }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- Diálogo de reglas compartidas -->
    <el-dialog v-model="rulesVisible" :title="T('ShareRules')" destroy-on-close :top="isMobile ? '0' : '5vh'" :width="isMobile ? '100%' : '80%'" :fullscreen="isMobile">
      <Rule :collection="clickRow" :is_my="1"></Rule>
    </el-dialog>
  </div>
</template>

<script setup>
import { T } from '@/utils/i18n'
import { computed, ref, onMounted, watch } from 'vue'
import { useRepositories } from '@/views/address_book/collection'
import Rule from '@/views/address_book/rule.vue'
import { CopyDocument, Edit, DeleteFilled, Link, CirclePlusFilled } from '@element-plus/icons-vue'

const {
  listRes,
  listQuery,
  getList,
  handlerQuery,
  del,
  formVisible,
  formData,
  toEdit,
  toAdd,
  submit,
} = useRepositories('my')

onMounted(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

const isHiperdino = computed(() => userInfo.value?.name === 'hiperdino')

const list = computed(_ => {
  if (listQuery.page > 1) {
    return listRes.list
  } else {
    return [
      { id: 0, name: T('MyAddressBook') },
      ...listRes.list,
    ]
  }
})

const clickRow = ref({})
const rulesVisible = ref(false)
const showRules = (row) => {
  clickRow.value = row
  rulesVisible.value = true
}

// Detectar si es móvil
const isMobile = ref(window.innerWidth <= 768)
window.addEventListener('resize', () => {
  isMobile.value = window.innerWidth <= 768
})
</script>

<style scoped lang="scss">
// MODO OSCURO SIEMPRE ACTIVO
.responsive-container {
  background-color: #1a1a1a;
  min-height: 100vh;
  color: #e0e0e0;
}

// Ocultar versión móvil en escritorio
.mobile-version {
  display: none;
}

// Mostrar versión escritorio por defecto
.desktop-version {
  display: block;
}

// Estilos modo oscuro para versión escritorio
.desktop-version {


  :deep(.el-table) {
    background-color: #2a2a2a;
    color: #e0e0e0;
    .el-table__header, .el-table__body {
      .el-table__row {
        &:hover {
          background-color: #3a3a3a;
        }
      }
    }
  }

  :deep(.el-button) {
    border-color: #3a3a3a;
    
    &.el-button--default {
      background-color: #3a3a3a;
      color: #e0e0e0;
      
      &:hover {
        background-color: #4a4a4a;
      }
    }
  }

  :deep(.el-pagination) {
    .btn-prev, .btn-next, .el-pager li {
      background-color: #3a3a3a;
      color: #e0e0e0;
      
      &:hover {
        color: #409eff;
      }
      
      &.is-active {
        background-color: #409eff;
        color: #ffffff;
      }
    }
  }
}

// RESPONSIVE: Cambiar a móvil en pantallas pequeñas
@media (max-width: 768px) {
  .desktop-version {
    display: none;
  }

  .mobile-version {
    display: block;
  }
  .el-button{
  padding: 1.1rem;
  font-size: 0.9rem;
  width: 100%;
}
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
      width: 100%;

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
        width: 100% !important;

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

// Ajustes para pantallas muy pequeñas
@media (max-width: 375px) {
  .mobile-actions .action-btn {
    font-size: 13px;
    padding: 8px 10px;
  }
  
  .list-item-card .card-title {
    font-size: 14px;
  }
  
  .list-item-card .card-actions .el-button {
    font-size: 12px;
    padding: 6px 10px;
  }
}
</style>