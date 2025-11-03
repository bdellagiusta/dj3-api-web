<template>
  <div class="address-book-container">
    <!-- Filter Card with Modern Design -->
    <el-card class="list-query" shadow="hover">
 <div class="mobile-header" v-if="isMobile">
  <div class="filter-title">
    <el-badge :value="activeFiltersCount" v-if="activeFiltersCount > 0" class="filter-badge" />
  </div>
  <el-button 
    class="filter-toggle" 
    color="#8B5CF6"
    @click="showFilters = !showFilters"
  >
    <el-icon v-if="showFilters"><Hide /></el-icon>
    <el-icon v-else><View /></el-icon>
    {{ showFilters ? T('Hide Filters') : T('Show Filters') }}
    <el-icon v-if="showFilters"><ArrowUp /></el-icon>
    <el-icon v-else><ArrowDown /></el-icon>
  </el-button>
</div>
      <el-form 
    :inline="!isMobile" 
    label-width="100px" 
    :class="{ 'mobile-form': isMobile, 'hidden-filters': isMobile && !showFilters }"
  >
       <el-form-item :label="T('Owner')">
      <el-select v-model="listQuery.user_id" clearable>
        <el-option v-for="item in allUsers" :key="item.id" :label="item.username" :value="item.id"></el-option>
      </el-select>
    </el-form-item>

    <el-form-item :label="T('Badge')">
      <el-select v-model="listQuery.collection_id" clearable>
        <el-option :value="0" :label="T('MyAddressBook')" v-if="!isHiperdino"></el-option>
        <el-option v-for="c in collectionListRes.list" :key="c.id" :label="c.name" :value="c.id"></el-option>
      </el-select>
    </el-form-item>

    <el-form-item :label="T('Name')">
      <el-input v-model="listQuery.alias" clearable @input="debouncedHandlerQuery"></el-input>
    </el-form-item>

    <el-form-item :label="T('Tags')">
      <el-select v-model="listQuery.tag_id" clearable filterable :placeholder="T('Select tags')">
        <el-option v-for="t in [...new Map(tagListRes.list.map(i => [i.name, i])).values()]" :key="t.id"
          :label="t.name" :value="t.name" />
      </el-select>
    </el-form-item>

    <el-form-item :class="{ 'full-width-button': isMobile }">
      <el-button type="primary" :icon="CirclePlusFilled" @click="toAdd" class="add-button">{{ T('Add') }}</el-button>
    </el-form-item>        
    <el-form-item class="form-actions">
          <el-button type="danger" :icon="RefreshLeft" @click="clearFilters" class="add-button">{{ T('Clear Filters') }}</el-button>
    </el-form-item>

  </el-form>
</el-card>

<!-- Desktop Table View -->
<el-card class="list-body desktop-view" shadow="hover" v-if="!isMobile">
  <el-table :data="listRes.list" v-loading="listRes.loading" border>
        <el-table-column prop="alias" :label="T('Name')" align="center" />


    <el-table-column prop="id" label="ID" align="center" width="200">
      <template #default="{ row }">
        <div>
          <PlatformIcons :name="platformList.find(p => p.label === row.platform)?.icon"
            style="width: 20px;height: 20px;display: inline-block" color="var(--basicBlack)" />
          {{ row.id }}
          <el-icon @click="handleClipboard(row.id, $event)">
            <CopyDocument />
          </el-icon>
        </div>
      </template>
    </el-table-column>
    <el-table-column prop="collection_id" :label="T('Group')" align="center" width="150">
      <template #default="{ row }">
        <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
        <span v-else>{{collectionListRes.list.find(c => c.id === row.collection_id)?.name}}</span>
      </template>
    </el-table-column>

    <el-table-column :label="T('Owner')" align="center" width="200">
      <template #default="{ row }">
        <span v-if="row.user_id"> <el-tag>{{allUsers?.find(u => u.id === row.user_id)?.username}}</el-tag> </span>
      </template>
    </el-table-column>

    <el-table-column :label="T('Tags')" align="center" width="200">
      <template #default="{ row }">
        <div v-if="row.tags && row.tags.length"
          style="display: flex; flex-wrap: wrap; gap: 4px; justify-content: center;">
          <el-tag v-for="(tag, index) in row.tags" :key="index" type="info" size="small">
            {{ tag }}
          </el-tag>
        </div>
        <span v-else>—</span>
      </template>
    </el-table-column>

    <el-table-column :label="T('Actions')" align="center" class-name="table-actions" width="400" fixed="right">
      <template #default="{ row }">
        <el-button type="success" :icon="Link"  @click="connectByClient(row.id)">{{ T('Link') }}</el-button>
        <el-button type="warning" :icon="Edit" @click="toEdit(row)">{{ T('Edit') }}</el-button>
        <el-button type="danger" :icon="DeleteFilled" @click="del(row)">{{ T('Delete') }}</el-button>
      </template>
    </el-table-column>
  </el-table>
</el-card>

<!-- Mobile Card View -->
<div class="mobile-list-view" v-if="isMobile" v-loading="listRes.loading">
  <el-card 
    class="mobile-item-card" 
    shadow="hover" 
    v-for="row in listRes.list" 
    :key="row.id"
  >
    <div class="card-header">
      <div class="card-title">
        <PlatformIcons 
          :name="platformList.find(p => p.label === row.platform)?.icon"
          class="platform-icon" 
          color="var(--basicBlack)" 
        />
        <span class="alias">{{ row.alias }}</span>
      </div>
      <el-tag v-if="row.user_id" size="small">
        {{ allUsers?.find(u => u.id === row.user_id)?.username }}
      </el-tag>
    </div>

    <div class="card-content">
      <div class="info-row">
        <span class="label">ID:</span>
        <span class="value">
          {{ row.id }}
          <el-icon @click="handleClipboard(row.id, $event)" class="copy-icon">
            <CopyDocument />
          </el-icon>
        </span>
      </div>

      <div class="info-row" v-if="row.collection_id !== undefined">
        <span class="label">{{ T('Badge') }}:</span>
        <span class="value">
          <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
          <span v-else>{{collectionListRes.list.find(c => c.id === row.collection_id)?.name}}</span>
        </span>
      </div>

      <div class="info-row" v-if="row.tags && row.tags.length">
        <span class="label">{{ T('Tags') }}:</span>
        <div class="tags-container">
          <el-tag v-for="(tag, index) in row.tags" :key="index" type="info" size="small">
            {{ tag }}
          </el-tag>
        </div>
      </div>
    </div>

    <div class="card-actions">
      <el-button :icon="Link" type="success" @click="connectByClient(row.id)" class="mobile-action-btn">
        {{ T('Link') }}
      </el-button>
      <el-button :icon="Edit"   type="warning" @click="toEdit(row)" class="mobile-action-btn">
        {{ T('Edit') }}
      </el-button>
      <el-button :icon="DeleteFilled" type="danger" @click="del(row)" class="mobile-action-btn">
        {{ T('Delete') }}
      </el-button>
    </div>
  </el-card>
</div>

<!-- Pagination -->
<el-card class="list-page" shadow="hover">
  <el-pagination 
    background 
    :layout="isMobile ? 'prev, pager, next' : 'prev, pager, next, sizes, jumper'" 
    :page-sizes="[10, 20, 50, 100]"
    :page-size="listQuery.page_size" 
    :current-page="listQuery.page" 
    :total="listRes.total"
    :small="isMobile"
    @size-change="handleSizeChange" 
    @current-change="handleCurrentChange" 
  />
</el-card>

<!-- Form Dialog -->
<el-dialog 
  v-model="formVisible" 
  :width="isMobile ? '95%' : '800px'" 
  :title="!formData.row_id ? T('Create') : T('Update')"
  :fullscreen="isMobile"
>
  <el-form 
    class="dialog-form" 
    ref="form" 
    :model="formData" 
    :label-width="isMobile ? 'auto' : '120px'"
    :label-position="isMobile ? 'top' : 'right'"
  >

    <el-form-item :label="T('Name')" prop="alias">
      <el-input v-model="formData.alias"></el-input>
    </el-form-item>

    <el-form-item :label="T('Owner')" prop="user_id" required>
      <el-select v-model="formData.user_id" @change="changeUserForUpdate">
        <el-option v-for="item in allUsers" :key="item.id" :label="item.username" :value="item.id"></el-option>
      </el-select>
    </el-form-item>

    <el-form-item :label="T('AddressBookName')">
      <el-select v-model="formData.collection_id" clearable @change="changeCollectionForUpdate">
        <el-option v-for="c in collectionListResForUpdate.list" :key="c.id" :label="c.name"
          :value="c.id"></el-option>
      </el-select>
    </el-form-item>

    <el-form-item label="ID" prop="id" required>
      <el-input v-model="formData.id"></el-input>
    </el-form-item>

    <el-form-item :label="T('Platform')" prop="platform">
      <el-select v-model="formData.platform">
        <el-option v-for="item in platformList" :key="item.value" :label="item.label"
          :value="item.value"></el-option>
      </el-select>
    </el-form-item>

    <el-form-item :label="T('Tags')" prop="tags">
      <el-select v-model="formData.tags" multiple>
        <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
          :value="item.name"></el-option>
      </el-select>
    </el-form-item>
 
    <el-form-item class="form-actions-dialog">
      <el-button @click="formVisible = false" :class="{ 'btn-block': isMobile }">
        {{ T('Cancel') }}
      </el-button>
      <el-button @click="submit" type="primary" :class="{ 'btn-block': isMobile }">
        {{ T('Submit') }}
      </el-button>
    </el-form-item>
  </el-form>
</el-dialog>
</div>
</template>
<script setup>
import { onActivated, onMounted, watch, ref } from 'vue'
import { useRepositories } from '@/views/address_book/index'
import { toWebClientLink } from '@/utils/webclient'
import { T } from '@/utils/i18n'
import { useRoute } from 'vue-router'
import { connectByClient } from '@/utils/peer'
import { useAppStore } from '@/store/app'
import { useUserStore } from '@/store/user'
import { handleClipboard } from '@/utils/clipboard'
import PlatformIcons from '@/components/icons/platform.vue'
import { loadAllUsers } from '@/global'
import { useResponsive } from '@/composables/useResponsive'
import { CopyDocument, ArrowDown, ArrowUp, Edit,  Link, View, Hide, Filter, RefreshLeft, Remove, DeleteFilled, CirclePlusFilled} from '@element-plus/icons-vue'

const appStore = useAppStore()
const userStore = useUserStore()
const route = useRoute()
const { allUsers, getAllUsers } = loadAllUsers()
const { isMobile, isTablet, isDesktop } = useResponsive()

const showFilters = ref(false)
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const {
  listRes,
  listQuery,
  getList,
  getTagList,
  handlerQuery,
  collectionListRes,
  getCollectionList,

  del,
  formVisible,
  platformList,
  formData,
  toEdit,
  toAdd,
  submit,
  changeUserForUpdate,
  changeCollectionForUpdate,
  collectionListResForUpdate,
  tagListRes,

  changeQueryUser,
} = useRepositories('admin')

if (route.query?.user_id) {
  listQuery.user_id = parseInt(route.query.user_id)
}

onMounted(getAllUsers)
onMounted(getList)
onMounted(getTagList)
onMounted(getCollectionList)
onActivated(getList)

// Debounce para el input de texto (espera 500ms después de que el usuario deje de escribir)
let debounceTimer = null
const debouncedHandlerQuery = () => {
  if (debounceTimer) {
    clearTimeout(debounceTimer)
  }
  debounceTimer = setTimeout(() => {
    handlerQuery()
  }, 500)
}

// Agregar después de los watch existentes
watch(() => listQuery.user_id, handlerQuery)
watch(() => listQuery.collection_id, handlerQuery)
watch(() => listQuery.tag_id, handlerQuery)
 
watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

const handleSizeChange = (val) => {
  listQuery.page_size = val
  listQuery.page = 1
  handlerQuery()
}

const handleCurrentChange = (val) => {
  listQuery.page = val
  getList()
}

// Función para limpiar todos los filtros
const clearFilters = () => {
  listQuery.alias = ''
  listQuery.user_id = null  // Agregar esta línea
  listQuery.collection_id = null
  listQuery.tag_id = null
  listQuery.page = 1
  handlerQuery()  // Cambiar getList() por handlerQuery()
}
</script>
<style scoped lang="scss">
.address-book-container {
  padding-bottom: 20px;
}

.list-query {
  margin-bottom: 16px;

  .filter-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    padding: 8px 0;
    font-weight: 500;
    user-select: none;

    .el-icon {
      transition: transform 0.3s;
      
      &.rotate-icon {
        transform: rotate(180deg);
      }
    }
  }
  .filter-toggle {
    width: 100%;
    
    :deep(.el-icon) {
      margin-right: 8px;
      margin-left: 8px;
    }
  }
  }

  .filter-form {
    .el-form-item {
      display: block;
      
      &.form-item-full {
        width: 100%;
      }
    }



  .el-select {
    --el-select-width: 160px;
  }
}

// Mobile form styles
.mobile-form {
  .el-form-item {
    display: block;
    margin: 20px 0;

    :deep(.el-form-item__label) {
      width: 100% !important;
      text-align: left;
      padding-bottom: 8px;
      display:block !important
    }

    :deep(.el-form-item__content) {
      margin-left: 0 !important;
    }

    .el-select,
    .el-input {
      width: 100%;
    }
  }

  &.hidden-filters {
    display: none;
  }
}

.full-width-button {
  width: 100%;
  
  .el-form-item__content {
    width: 100%;
  }

  .add-button {
    width: 100%;
  }
}

// Desktop table view
.desktop-view {
  .colors {
    display: flex;
    justify-content: center;
    align-items: center;

    .colorbox {
      width: 50px;
      height: 30px;
      display: flex;
      justify-content: center;
      align-items: center;

      .dot {
        width: 10px;
        height: 10px;
        display: block;
        border-radius: 50%;
      }
    }
  }
}

// Mobile list view
.mobile-list-view {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 16px;

  .mobile-item-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #ebeef5;

      .card-title {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;

        .platform-icon {
          width: 24px;
          height: 24px;
          flex-shrink: 0;
        }

        .alias {
          font-weight: 600;
          font-size: 16px;
          word-break: break-word;
        }
      }
    }

    .card-content {
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-bottom: 16px;

      .info-row {
        display: flex;
        align-items: flex-start;
        gap: 8px;
        font-size: 14px;

        .label {
          font-weight: 500;
          color: #f2f3f3;
          min-width: 60px;
          flex-shrink: 0;
        }

        .value {
          color: #eeeeee;
          word-break: break-all;
          flex: 1;
          display: flex;
          align-items: center;
          gap: 8px;

          .copy-icon {
            cursor: pointer;
            flex-shrink: 0;
            
            &:hover {
              color: #409eff;
            }
          }
        }

        .tags-container {
          display: flex;
          flex-wrap: wrap;
          gap: 6px;
          flex: 1;
        }
      }
    }

    .card-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      padding-top: 12px;
      border-top: 1px solid #ebeef5;

      .mobile-action-btn {
        margin: 0 !important;
        min-height: 35px;
        
        &:first-child {
          width: 100%;
        }
        
        &:not(:first-child) {
          flex: 1;
          min-width: calc(50% - 4px);
        }
      }
    }
  }
}

// Pagination
.list-page {
  :deep(.el-pagination) {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
  }
}

// Dialog mobile styles
.dialog-form {
  .el-select,
  .el-input {
    width: 100%;
  }

  .mobile-form-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-top: 20px;

    :deep(.el-form-item__content) {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
  }
}

// Responsive breakpoints
@media (max-width: 768px) {
  .address-book-container {
    padding: 0 8px 16px;
  }  
  .el-button{
        width: 100%;
        padding: 1.1rem;
  }
  .add-button {
    width: 100%;
  }
  .list-query,
  .list-page {
    margin-left: -8px;
    margin-right: -8px;
    border-radius: 0;
  }

  .el-card {
    :deep(.el-card__body) {
      padding: 16px;
    }
  }
}

@media (min-width: 769px) {
  .mobile-list-view {
    display: none;
  }
}

@media (max-width: 768px) {
  .desktop-view {
    display: none;
  }
}
</style>