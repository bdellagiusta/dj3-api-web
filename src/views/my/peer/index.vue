<template>
  <div class="peers-container">
    <!-- Mobile Filter Toggle -->
    <el-card class="list-query" shadow="hover">
      <div class="filter-header" @click="toggleFilters" v-if="isMobile">
        <span>{{ T('Filters') }}</span>
        <el-icon :class="{ 'rotate-icon': showFilters }">
          <ArrowDown />
        </el-icon>
      </div>

      <el-form 
        :inline="!isMobile" 
        :label-width="isMobile ? 'auto' : '150px'"
        :class="{ 'mobile-form': isMobile, 'hidden-filters': isMobile && !showFilters }"
      >
        <el-form-item label="ID">
          <el-input v-model="listQuery.id" clearable />
        </el-form-item>
        <el-form-item :label="T('Hostname')">
          <el-input v-model="listQuery.hostname" clearable />
        </el-form-item>
        <el-form-item :label="T('LastOnlineTime')">
          <el-select v-model="listQuery.time_ago" clearable>
            <el-option v-for="item in timeFilters" :key="item.value" :label="item.text" :value="item.value"
              :disabled="item.value === 0"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :class="{ 'mobile-buttons': isMobile }">
          <el-button type="primary" @click="handlerQuery" :class="{ 'mobile-btn': isMobile }">
            {{ T('Filter') }}
          </el-button>
          <el-button type="success" @click="toExport" :class="{ 'mobile-btn': isMobile }">
            {{ T('Export') }}
          </el-button>
          <el-button type="primary" @click="toBatchAddToAB" :class="{ 'mobile-btn': isMobile }">
            {{ T('BatchAddToAB') }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Desktop Table View -->
    <el-card class="list-body desktop-view" shadow="hover" v-if="!isMobile">
      <el-table :data="listRes.list" v-loading="listRes.loading" border size="small"
        @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column prop="id" label="ID" align="center" width="150">
          <template #default="{ row }">
            <span>{{ row.id }} <el-icon @click="handleClipboard(row.id, $event)">
                <CopyDocument />
              </el-icon></span>
          </template>
        </el-table-column>
        <el-table-column prop="cpu" label="CPU" align="center" width="100" show-overflow-tooltip />
        <el-table-column prop="hostname" :label="T('Hostname')" align="center" width="120" />
        <el-table-column prop="memory" :label="T('Memory')" align="center" width="120" />
        <el-table-column prop="os" :label="T('Os')" align="center" width="120" show-overflow-tooltip />
        <el-table-column prop="last_online_time" :label="T('LastOnlineTime')" align="center" min-width="120">
          <template #default="{ row }">
            <div class="last_oline_time">
              <span> {{ row.last_online_time ? timeAgo(row.last_online_time * 1000) : '-' }}</span> 
              <span class="dot" :class="{ red: timeDis(row.last_online_time) >= 60, green: timeDis(row.last_online_time) < 60 }"></span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="last_online_ip" :label="T('LastOnlineIp')" align="center" min-width="120" />
        <el-table-column prop="username" :label="T('Username')" align="center" width="120" />
        <el-table-column prop="uuid" :label="T('Uuid')" align="center" width="120" show-overflow-tooltip />
        <el-table-column prop="version" :label="T('Version')" align="center" width="80" />
        <el-table-column prop="alias" :label="T('Alias')" align="center" width="80" />
        <el-table-column prop="created_at" :label="T('CreatedAt')" align="center" width="150" />
        <el-table-column prop="updated_at" :label="T('UpdatedAt')" align="center" width="150" />
        <el-table-column :label="T('Actions')" align="center" width="500" class-name="table-actions" fixed="right">
          <template #default="{ row }">
            <el-button type="success" @click="connectByClient(row.id)">{{ T('Link') }}</el-button>
            <el-button v-if="appStore.setting.appConfig.web_client" type="success" @click="toWebClientLink(row)">Web Client</el-button>
            <el-button type="primary" @click="toAddressBook(row)">{{ T('AddToAddressBook') }}</el-button>
            <el-button @click="toView(row)">{{ T('View') }}</el-button>
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
          <el-checkbox 
            :model-value="isSelected(row)" 
            @change="toggleSelection(row)"
            class="mobile-checkbox"
          />
          <div class="card-title">
            <span class="peer-id">{{ row.id }}</span>
            <el-icon @click="handleClipboard(row.id, $event)" class="copy-icon">
              <CopyDocument />
            </el-icon>
          </div>
          <span 
            class="status-dot" 
            :class="{ red: timeDis(row.last_online_time) >= 60, green: timeDis(row.last_online_time) < 60 }"
          ></span>
        </div>

        <div class="card-content">
          <div class="info-row" v-if="row.hostname">
            <span class="label">{{ T('Hostname') }}:</span>
            <span class="value">{{ row.hostname }}</span>
          </div>

          <div class="info-row" v-if="row.alias">
            <span class="label">{{ T('Alias') }}:</span>
            <span class="value">{{ row.alias }}</span>
          </div>

          <div class="info-row" v-if="row.username">
            <span class="label">{{ T('Username') }}:</span>
            <span class="value">{{ row.username }}</span>
          </div>

          <div class="info-row">
            <span class="label">{{ T('Os') }}:</span>
            <span class="value">{{ row.os || '-' }}</span>
          </div>

          <div class="info-row">
            <span class="label">CPU / {{ T('Memory') }}:</span>
            <span class="value">{{ row.cpu || '-' }} / {{ row.memory || '-' }}</span>
          </div>

          <div class="info-row">
            <span class="label">{{ T('LastOnlineTime') }}:</span>
            <span class="value">{{ row.last_online_time ? timeAgo(row.last_online_time * 1000) : '-' }}</span>
          </div>

          <div class="info-row" v-if="row.last_online_ip">
            <span class="label">{{ T('LastOnlineIp') }}:</span>
            <span class="value">{{ row.last_online_ip }}</span>
          </div>

          <div class="info-row" v-if="row.version">
            <span class="label">{{ T('Version') }}:</span>
            <span class="value">{{ row.version }}</span>
          </div>
        </div>

        <div class="card-actions">
          <el-button type="success" @click="connectByClient(row.id)" class="mobile-action-btn">
            {{ T('Link') }}
          </el-button>
          <el-button 
            v-if="appStore.setting.appConfig.web_client" 
            type="success" 
            @click="toWebClientLink(row)"
            class="mobile-action-btn"
          >
            Web Client
          </el-button>
          <el-button type="primary" @click="toAddressBook(row)" class="mobile-action-btn">
            {{ T('AddToAddressBook') }}
          </el-button>
          <el-button @click="toView(row)" class="mobile-action-btn">
            {{ T('View') }}
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
        v-model:page-size="listQuery.page_size" 
        v-model:current-page="listQuery.page" 
        :total="listRes.total"
        :small="isMobile"
      >
      </el-pagination>
    </el-card>

    <!-- View Dialog -->
    <el-dialog 
      v-model="formVisible" 
      :title="T('Information')" 
      :width="isMobile ? '95%' : '800px'"
      :fullscreen="isMobile"
    >
      <el-form 
        class="dialog-form" 
        ref="form" 
        :model="formData" 
        :label-width="isMobile ? 'auto' : '120px'"
        :label-position="isMobile ? 'top' : 'right'"
      >
        <el-form-item label="ID" prop="id">
          <el-input v-model="formData.id" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Username')" prop="username">
          <el-input v-model="formData.username" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Hostname')" prop="hostname">
          <el-input v-model="formData.hostname" disabled></el-input>
        </el-form-item>
        <el-form-item label="CPU" prop="cpu">
          <el-input v-model="formData.cpu" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Memory')" prop="memory">
          <el-input v-model="formData.memory" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Os')" prop="os">
          <el-input v-model="formData.os" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Uuid')" prop="uuid">
          <el-input v-model="formData.uuid" disabled></el-input>
        </el-form-item>
        <el-form-item :label="T('Version')" prop="version">
          <el-input v-model="formData.version" disabled></el-input>
        </el-form-item>
      </el-form>
    </el-dialog>

    <!-- Add to Address Book Dialog -->
    <el-dialog 
      v-model="ABFormVisible" 
      :width="isMobile ? '95%' : '800px'" 
      :title="T('Create')"
      :fullscreen="isMobile"
    >
      <el-form 
        class="dialog-form" 
        ref="form" 
        :model="ABFormData" 
        :label-width="isMobile ? 'auto' : '120px'"
        :label-position="isMobile ? 'top' : 'right'"
      >
        <el-form-item :label="T('AddressBookName')" required prop="collection_id">
          <el-select v-model="ABFormData.collection_id" clearable @change="changeCollectionForUpdate">
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListResForUpdate.list" :key="c.id" :label="c.name"
              :value="c.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="ID" prop="id" required>
          <el-input v-model="ABFormData.id"></el-input>
        </el-form-item>
        <el-form-item :label="T('Username')" prop="username">
          <el-input v-model="ABFormData.username"></el-input>
        </el-form-item>
        <el-form-item :label="T('Alias')" prop="alias">
          <el-input v-model="ABFormData.alias"></el-input>
        </el-form-item>
        <el-form-item :label="T('Hostname')" prop="hostname">
          <el-input v-model="ABFormData.hostname"></el-input>
        </el-form-item>
        <el-form-item :label="T('Platform')" prop="platform">
          <el-select v-model="ABFormData.platform">
            <el-option v-for="item in ABPlatformList" :key="item.value" :label="item.label"
              :value="item.value"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="T('Tags')" prop="tags">
          <el-select v-model="ABFormData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :class="{ 'mobile-form-actions': isMobile }">
          <el-button @click="ABFormVisible = false" :class="{ 'mobile-btn': isMobile }">
            {{ T('Cancel') }}
          </el-button>
          <el-button @click="ABSubmit" type="primary" :class="{ 'mobile-btn': isMobile }">
            {{ T('Submit') }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-dialog>

    <!-- Batch Add to Address Book Dialog -->
    <el-dialog 
      v-model="batchABFormVisible" 
      :width="isMobile ? '95%' : '800px'" 
      :title="T('Create')"
      :fullscreen="isMobile"
    >
      <el-form 
        class="dialog-form" 
        ref="form" 
        :model="batchABFormData" 
        :label-width="isMobile ? 'auto' : '120px'"
        :label-position="isMobile ? 'top' : 'right'"
      >
        <el-form-item :label="T('AddressBookName')" required prop="collection_id">
          <el-select v-model="batchABFormData.collection_id" clearable @change="changeCollectionForBatchCreateAB">
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListResForUpdate.list" :key="c.id" :label="c.name"
              :value="c.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="T('Tags')" prop="tags">
          <el-select v-model="batchABFormData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :class="{ 'mobile-form-actions': isMobile }">
          <el-button @click="batchABFormVisible = false" :class="{ 'mobile-btn': isMobile }">
            {{ T('Cancel') }}
          </el-button>
          <el-button @click="submitBatchAddToAB" type="primary" :class="{ 'mobile-btn': isMobile }">
            {{ T('Submit') }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onActivated, onMounted, reactive, ref, watch } from 'vue'
import { list } from '@/api/my/peer'
import { ElMessage, ElMessageBox } from 'element-plus'
import { toWebClientLink } from '@/utils/webclient'
import { T } from '@/utils/i18n'
import { timeAgo } from '@/utils/time'
import { jsonToCsv, downBlob } from '@/utils/file'
import { useRepositories as useABRepositories } from '@/views/address_book/index'
import { useAppStore } from '@/store/app'
import { connectByClient } from '@/utils/peer'
import { CopyDocument, ArrowDown, ArrowUp, Filter} from '@element-plus/icons-vue'
import { handleClipboard } from '@/utils/clipboard'
import { batchCreateFromPeers } from '@/api/my/address_book'

// Responsive composable inline
const isMobile = ref(false)
const checkScreen = () => {
  isMobile.value = window.innerWidth < 768
}
onMounted(() => {
  checkScreen()
  window.addEventListener('resize', checkScreen)
})

const showFilters = ref(false)
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const appStore = useAppStore()
const listRes = reactive({
  list: [], total: 0, loading: false,
})
const listQuery = reactive({
  page: 1,
  page_size: 10,
  time_ago: null,
  id: '',
  hostname: '',
})

const getList = async () => {
  listRes.loading = true
  const res = await list(listQuery).catch(_ => false)
  listRes.loading = false
  if (res) {
    listRes.list = res.data.list
    listRes.total = res.data.total
  }
}
const handlerQuery = () => {
  if (listQuery.page === 1) {
    getList()
  } else {
    listQuery.page = 1
  }
}

onMounted(getList)
onActivated(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

const formVisible = ref(false)
const formData = reactive({
  row_id: 0,
  cpu: '',
  hostname: '',
  id: '',
  memory: '',
  os: '',
  username: '',
  uuid: '',
  version: '',
})

const toView = (row) => {
  formVisible.value = true
  Object.keys(formData).forEach(key => {
    formData[key] = row[key]
  })
}

const timeDis = (time) => {
  let now = new Date().getTime()
  let after = new Date(time * 1000).getTime()
  return (now - after) / 1000
}

const timeFilters = computed(() => [
  { text: T('MinutesLess', { param: 1 }, 1), value: -60 },
  { text: T('HoursLess', { param: 1 }, 1), value: -3600 },
  { text: T('DaysLess', { param: 1 }, 1), value: -86400 },
  { text: '---------', value: 0 },
  { text: T('MinutesAgo', { param: 1 }, 1), value: 60 },
  { text: T('HoursAgo', { param: 1 }, 1), value: 3600 },
  { text: T('DaysAgo', { param: 1 }, 1), value: 86400 },
  { text: T('MonthsAgo', { param: 1 }, 1), value: 2592000 },
])

const toExport = async () => {
  const q = { ...listQuery }
  q.page_size = 10000
  q.page = 1
  const res = await list(q).catch(_ => false)
  if (res) {
    const data = res.data.list.map(item => {
      item.last_online_time = item.last_online_time ? new Date(item.last_online_time * 1000).toLocaleString() : '-'
      delete item.user_id
      delete item.user
      return item
    })
    const csv = jsonToCsv(data)
    downBlob(csv, 'peers.csv')
  }
}

const {
  platformList: ABPlatformList,
  formVisible: ABFormVisible,
  formData: ABFormData,
  collectionListResForUpdate,
  getCollectionListForUpdate,
  tagListRes,
  changeCollectionForUpdate,
  submit: ABSubmit,
  fromPeer,
} = useABRepositories('my')
onMounted(getCollectionListForUpdate)
const toAddressBook = (peer) => {
  fromPeer(peer)
  ABFormVisible.value = true
}

const multipleSelection = ref([])
const handleSelectionChange = (val) => {
  multipleSelection.value = val
}

// Mobile selection helpers
const isSelected = (row) => {
  return multipleSelection.value.some(item => item.id === row.id)
}

const toggleSelection = (row) => {
  const index = multipleSelection.value.findIndex(item => item.id === row.id)
  if (index > -1) {
    multipleSelection.value.splice(index, 1)
  } else {
    multipleSelection.value.push(row)
  }
}

const batchABFormVisible = ref(false)
const toBatchAddToAB = () => {
  batchABFormVisible.value = true
}
const batchABFormData = ref({
  collection_id: 0,
  tags: [],
  peer_ids: [],
})
const changeCollectionForBatchCreateAB = (val) => {
  batchABFormData.value.tags = []
  changeCollectionForUpdate(val)
}
const submitBatchAddToAB = async () => {
  if (multipleSelection.value.length === 0) {
    ElMessage.warning(T('PleaseSelectData'))
    return false
  }
  batchABFormData.value.peer_ids = multipleSelection.value.map(i => i.row_id)
  if (!batchABFormData.value.peer_ids.length) {
    ElMessage.warning(T('PleaseSelectData'))
    return false
  }

  const res = await batchCreateFromPeers(batchABFormData.value).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    batchABFormVisible.value = false
  }
}
</script>

<style scoped lang="scss">
.peers-container {
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

  .el-select {
    --el-select-width: 180px;
  }
}

// Mobile form styles
.mobile-form {
  .el-form-item {
    display: block;
    margin-bottom: 16px;

    :deep(.el-form-item__label) {
      width: 100% !important;
      text-align: left;
      padding-bottom: 8px;
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

.mobile-buttons {
  width: 100%;
  
  :deep(.el-form-item__content) {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .mobile-btn {
    width: 100%;
  }
}

// Desktop table view
.desktop-view {
  .last_oline_time {
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .dot {
    width: 6px;
    height: 6px;
    display: block;
    border-radius: 50%;
    margin-left: 10px;

    &.red {
      background-color: red;
    }

    &.green {
      background-color: green;
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
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #ebeef5;

      .mobile-checkbox {
        flex-shrink: 0;
      }

      .card-title {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;

        .peer-id {
          font-weight: 600;
          font-size: 16px;
          word-break: break-all;
        }

        .copy-icon {
          cursor: pointer;
          flex-shrink: 0;
          
          &:hover {
            color: #409eff;
          }
        }
      }

      .status-dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        flex-shrink: 0;

        &.red {
          background-color: red;
        }

        &.green {
          background-color: green;
        }
      }
    }

    .card-content {
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin-bottom: 16px;
      font-size: 14px;

      .info-row {
        display: flex;
        gap: 8px;

        .label {
          font-weight: 500;
          color: #606266;
          min-width: 110px;
          flex-shrink: 0;
        }

        .value {
          color: #303133;
          word-break: break-word;
          flex: 1;
        }
      }
    }

    .card-actions {
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding-top: 12px;
      border-top: 1px solid #ebeef5;

      .mobile-action-btn {
        width: 100%;
        min-height: 44px;
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

    .mobile-btn {
      width: 100%;
      min-height: 44px;
    }
  }
}

// Responsive breakpoints
@media (max-width: 768px) {
  .peers-container {
    padding: 0 8px 16px;
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