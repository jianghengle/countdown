<template>
  <div class="container main-container">
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div v-if="audios">
      <div class="columns is-multiline">
        <div class="column is-half audio-block" v-for="(a, i) in audios">
          <div class="field">
            <div class="control">
              <input class="input" type="text" placeholder="Name" v-model="a.audioName" @blur="audioChanged(i)">
            </div>
          </div>
          <audio controls>
            <source :src="a.audioUrl">
          </audio>
        </div>

        <div v-if="uploading" class="column is-half audio-block">
          <div class="percentage">{{percentage}}%</div>
          <progress class="progress" :value="percentage" max="100">{{percentage}}%</progress>
        </div>
      </div>

      <div v-if="!uploading" class="file upload-button">
        <label class="file-label">
          <input class="file-input" type="file" accept="audio/*" @change="onFileChange">
          <span class="file-cta">
            <span class="file-icon">
              <v-icon name="upload"/>
            </span>
            <span class="file-label">
              Upload a file…
            </span>
          </span>
        </label>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'audios',
  data () {
    return {
      waiting: false,
      error: '',
      uploading: false,
      percentage: 0,
      audios: null,
      oldAudios: null
    }
  },
  methods: {
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      var file = files[0]

      var formData = new FormData()
      formData.append('file', file)

      this.uploading = true
      var vm = this
      this.$http.post(xHTTPx + '/upload_audio', formData, {
        before: request => {
          vm.percentage = 0
        },
        progress: e => {
          vm.percentage = Math.round((e.loaded / e.total) * 100)
        }
      }).then(response => {
        var resp = response.body 
        this.audios.push({
          audioName: resp.audioName,
          audioFile: resp.audioFile,
          audioUrl: xHTTPx + '/audios/' + encodeURIComponent(resp.audioFile)
        })
        this.oldAudios.push(resp)
        this.uploading = false
        this.error = ''
      }, response => {
        this.error = 'Failed to upload audio!'
        this.uploading = false
      })
    },
    audioChanged (i) {
      var audio = this.audios[i]
      var oldAudio = this.oldAudios[i]
      if(audio.audioName.trim() == oldAudio.audioName)
        return
      var message = {
        oldAudioName: oldAudio.audioName,
        newAudioName: audio.audioName.trim(),
      }
      this.$http.post(xHTTPx + '/update_audio', message).then(response => {
        var resp = response.body
        var newAudio = {
          audioName: resp.audioName,
          audioFile: resp.audioFile,
          audioUrl: xHTTPx + '/audios/' + encodeURIComponent(resp.audioFile)
        }
        this.audios.splice(i, 1, newAudio)
        this.oldAudios.splice(i, 1, resp)
      }, response => {
        this.error = 'Failed to update audio!'
      })
    }
  },
  mounted () {
    this.waiting = true
    this.$http.get(xHTTPx + '/get_audios').then(response => {
      var resp = response.body.sort(function(a, b){
        return a.audioName.localeCompare(b.audioName)
      })
      this.audios = resp.map(function(a){
        return {
          audioName: a.audioName,
          audioFile: a.audioFile,
          audioUrl: xHTTPx + '/audios/' + encodeURIComponent(a.audioFile)
        }
      })
      this.oldAudios = resp
      this.waiting = false
    }, response => {
      this.error = 'Failed to get audios!'
      this.waiting = false
    })
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.main-container {
  margin-top: 10px;
  padding: 10px;
}

.audio-block {
  padding: 1.25rem;
}

.percentage {
  text-align: center;
  margin-top: 15px;
  margin-bottom: 5px;
}

.upload-button {
  margin-left: 10px;
}

</style>
