<template>
  <div>

    <el-card class="list-query" shadow="hover">
      <el-form inline label-width="120px">
        <el-form-item :label="T('Name')">
          <el-input v-model="listQuery.alias" clearable></el-input>
        </el-form-item>
        <!-- <el-form-item v-if="isAdmin" :label="T('AddressBookName')">
          <el-select v-model="listQuery.collection_id" clearable>
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListRes.list" :key="c.id" :label="c.name" :value="c.id"></el-option>
          </el-select>
        </el-form-item> -->

    <el-form-item v-if="!isAdmin" :label="T('Islands')">
  <el-select 
    v-model="listQuery.tag_id" 
    clearable 
    filterable 
    :placeholder="T('Select island')">
    <el-option v-for="t in tagListRes.list" :key="t.id" :label="t.name" :value="t.name" />
  </el-select>
</el-form-item>

    <el-form-item v-if="isAdmin" :label="T('Tags')">
  <el-select 
    v-model="listQuery.tag_id" 
    clearable 
    filterable 
    :placeholder="T('Select tags')">
    <el-option v-for="t in tagListRes.list" :key="t.id" :label="t.name" :value="t.name" />
  </el-select>
</el-form-item>



        <el-form-item :label="T('Id')">
          <el-input v-model="listQuery.id" clearable></el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handlerQuery">{{ T('Filter') }}</el-button>
          <el-button v-if="isAdmin" type="danger" @click="toAdd">{{ T('Add') }}</el-button>
          <el-button v-if="isAdmin" type="primary" @click="showBatchEditTags">{{ T('BatchEditTags') }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <el-card class="list-body" shadow="hover">

      <el-table :data="listRes.list" v-loading="listRes.loading" border @selection-change="handleSelectionChange">
        <el-table-column v-if="isAdmin" type="selection" width="50" align="center"></el-table-column>
        <el-table-column prop="alias" :label="T('Name')" align="center" />
        <el-table-column prop="id" label="ID" align="center" width="250">
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
        <!-- <el-table-column v-if="isAdmin" prop="collection_id" :label="T('AddressBookName')" align="center" width="150">
          <template #default="{ row }">
            <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{collectionListRes.list.find(c => c.id === row.collection_id)?.name}}</span>
          </template>
        </el-table-column> -->
        <el-table-column v-if="isAdmin" prop="platform" :label="T('Platform')" align="center" width="250" />
        <el-table-column prop="tags" v-if="!isAdmin" :label="T('Island')" align="center" width="250" />
          <el-table-column prop="tags" v-if="isAdmin" :label="T('Tags')" align="center" width="250" />
        <!-- <el-table-column v-if="isAdmin" prop="peer.version" :label="T('Version')" align="center" width="100" /> -->
        <el-table-column :label="T('Actions')" align="center" class-name="table-actions" fixed="right" width="300" >
          <template #default="{ row }" >
            <el-button type="success" @click="connectByClient(row.id)">{{ T('Link') }}</el-button>
            <template v-if="isAdmin">
              <el-button @click="toEdit(row)">{{ T('Edit') }}</el-button>
              <el-button type="danger" @click="del(row)">{{ T('Delete') }}</el-button>
            </template>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
<el-card class="list-page" shadow="hover">
  
  <el-pagination 
    background 
    layout="prev, pager, next, sizes, jumper" 
    :page-sizes="[10, 20, 50, 100]"
    :page-size="listQuery.page_size"
    :current-page="listQuery.page"
    :total="listRes.total"
    @size-change="handleSizeChange"
    @current-change="handleCurrentChange"
  />
</el-card>
    <el-dialog v-model="formVisible" width="800" :title="!formData.row_id ? T('Create') : T('Update')">
      <el-form class="dialog-form" ref="form" :model="formData" label-width="120px">

        <el-form-item label="ID" prop="id" required>
          <el-input v-model="formData.id"></el-input>
        </el-form-item>
        <el-form-item :label="T('Name')" prop="alias">
          <el-input v-model="formData.alias"></el-input>
        </el-form-item>
        <el-form-item  v-if="isAdmin"  :label="T('Platform')" prop="platform">
          <el-select v-model="formData.platform">
            <el-option v-for="item in platformList" :key="item.value" :label="item.label"
              :value="item.value"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item v-if="!isAdmin" :label="T('Island')" prop="tags">
          <el-select v-model="formData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
          <el-form-item v-if="isAdmin" :label="T('Tags')" prop="tags">
          <el-select v-model="formData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="formVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submit" type="primary">{{ T('Submit') }}</el-button>
          
        </el-form-item>
      </el-form>
    </el-dialog>
    <el-dialog v-model="shareToWebClientVisible" width="900" :close-on-click-modal="false">
      <shareByWebClient :id="shareToWebClientForm.id" :hash="shareToWebClientForm.hash"
        @cancel="shareToWebClientVisible = false" @success="" />
    </el-dialog>
    <el-dialog v-model="batchEditTagVisible" width="800">
      <el-form :model="batchEditTagsFormData" label-width="120px" class="dialog-form">
        <el-form-item :label="T('Tags')" prop="tags">
          <el-select v-model="batchEditTagsFormData.tags" multiple>
            <el-option v-for="item in tagListResForBatchEdit.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="batchEditTagVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submitBatchEditTags" type="primary">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup>
import { onActivated, onMounted, reactive, ref, watch, computed } from 'vue'
import { useBatchUpdateTagsRepositories, useRepositories } from '@/views/address_book'
import { T } from '@/utils/i18n'
import shareByWebClient from '@/views/address_book/components/shareByWebClient.vue'
import { useAppStore } from '@/store/app'
import { connectByClient } from '@/utils/peer'
import { handleClipboard } from '@/utils/clipboard'
import { CopyDocument } from '@element-plus/icons'
import PlatformIcons from '@/components/icons/platform.vue'

const appStore = useAppStore()

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
  tagListRes,
  changeCollectionForUpdate,
  getCollectionListForUpdate,
  collectionListResForUpdate,

} = useRepositories('my')


// Obtener información del usuario desde localStorage
const userInfo = computed(() => {
  const userStr = localStorage.getItem('user_info')
  return userStr ? JSON.parse(userStr) : null
})

const currentUsername = computed(() => userInfo.value?.name || '')

// Verificar si es admin
const isAdmin = computed(() => userInfo.value?.name === 'admin')

onMounted(getCollectionList)
onMounted(getCollectionListForUpdate)
onMounted(getList)
onMounted(getTagList)
onActivated(getList)

watch(() => listQuery.page, getList)

watch(() => listQuery.page_size, handlerQuery)

const shareToWebClientVisible = ref(false)
const shareToWebClientForm = reactive({
  id: '',
  hash: '',
  alias: '',

})
const toShowShare = (row) => {
  shareToWebClientForm.id = row.id
  shareToWebClientForm.hash = row.hash
  shareToWebClientForm.alias = row.alias
  shareToWebClientVisible.value = true
}
const {
  tagListRes: tagListResForBatchEdit,
  getTagList: getTagListForBatchEdit,
  visible: batchEditTagVisible,
  show: showBatchEditTags,
  formData: batchEditTagsFormData,
  submit: _submitBatchEditTags,
} = useBatchUpdateTagsRepositories()
onMounted(getTagListForBatchEdit)
const submitBatchEditTags = async () => {
  const res = await _submitBatchEditTags().catch(_ => false)
  if (res) {
    getList()
  }
}

const multipleSelection = ref([])
const handleSelectionChange = (val) => {
  multipleSelection.value = val

  batchEditTagsFormData.value.row_ids = val.map(v => v.row_id)
}


const handleSizeChange = (val) => {
  listQuery.page_size = val
  listQuery.page = 1 // Resetear a la primera página al cambiar el tamaño
  getList()
}

const handleCurrentChange = (val) => {
  listQuery.page = val
  getList()
}

</script>

<style scoped lang="scss">
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
</style>
