<template>
  <div class="container main-container">
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div v-if="images">
      <div class="columns is-multiline">
        <div class="column is-half level is-mobile picture-block" v-for="(image, i) in images">
          <div class="level-item image-container" :style="{'width': imageSize+'px', 'height': imageSize+'px'}" @click="playImage(i)">
            <img class="my-image" :src="image.imageUrl" />
          </div>
          <div class="level-item image-options" :style="{'height': imageSize+'px'}">
            <div class="field">
              <div class="control">
                <input class="input" type="text" placeholder="Name" v-model="image.imageName" @blur="imageChanged(i)">
              </div>
            </div>
            <div class="field">
              <div class="control">
                <div class="select">
                  <select v-model="image.audioName" @change="imageChanged(i)">
                    <option v-for="audio in audios">{{audio}}</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="uploading" class="column is-half level is-mobile picture-block">
          <div class="level-item image-container" :style="{'width': imageSize+'px', 'height': imageSize+'px'}">
            <div class="percentage" :style="{'margin-top': imageSize*0.4+'px'}">{{percentage}}%</div>
            <progress class="progress" :value="percentage" max="100">{{percentage}}%</progress>
          </div>
          <div class="level-item image-options" :style="{'height': imageSize+'px'}">
            <div class="field">
              <div class="control">
                <input class="input" type="text" placeholder="Name">
              </div>
            </div>
            <div class="field">
              <div class="control">
                <div class="select">
                  <select>
                    <option>Tada</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="!uploading" class="file upload-button">
        <label class="file-label">
          <input class="file-input" type="file" accept="image/*" @change="onFileChange">
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
  name: 'images',
  data () {
    return {
      waiting: false,
      error: '',
      windowWidth: 0,
      uploading: false,
      percentage: 0,
      images: null,
      oldImages: null,
      audios: []
    }
  },
  computed: {
    imageSize () {
      return this.windowWidth > 670 ? 200 : this.windowWidth / 4
    }
  },
  methods: {
    playImage (index) {
      var image = this.images[index]
      this.$router.push('/start/' + btoa(encodeURIComponent(image.imageName)))
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      var file = files[0]

      var formData = new FormData()
      formData.append('file', file)

      this.uploading = true
      var vm = this
      this.$http.post(xHTTPx + '/upload_image', formData, {
        before: request => {
          vm.percentage = 0
        },
        progress: e => {
          vm.percentage = Math.round((e.loaded / e.total) * 100)
        }
      }).then(response => {
        var resp = response.body 
        this.images.push({
          imageName: resp.imageName,
          audioName: resp.audioName,
          imageUrl: xHTTPx + '/images/' + encodeURIComponent(resp.imageFile)
        })
        this.oldImages.push(resp)
        this.uploading = false
        this.error = ''
      }, response => {
        this.error = 'Failed to upload image!'
        this.uploading = false
      })
    },
    handleResize () {
      this.windowWidth = window.innerWidth
    },
    imageChanged (i) {
      var image = this.images[i]
      var oldImage = this.oldImages[i]
      if(image.imageName.trim() == oldImage.imageName && image.audioName == oldImage.audioName)
        return
      var message = {
        newImageName: image.imageName.trim(),
        oldImageName: oldImage.imageName,
        newAudioName: image.audioName,
      }
      this.$http.post(xHTTPx + '/update_image', message).then(response => {
        var resp = response.body
        var newImage = {
          imageName: resp.imageName,
          audioName: resp.audioName,
          imageUrl: xHTTPx + '/images/' + encodeURIComponent(resp.imageFile)
        }
        this.images.splice(i, 1, newImage)
        this.oldImages.splice(i, 1, resp)
      }, response => {
        this.error = 'Failed to update image!'
      })
    }
  },
  mounted () {
    this.waiting = true
    this.$http.get(xHTTPx + '/get_images').then(response => {
      var resp = response.body.sort(function(a, b){
        return a.imageName.localeCompare(b.imageName)
      })
      this.images = resp.map(function(i){
        return {
          imageName: i.imageName,
          audioName: i.audioName,
          imageUrl: xHTTPx + '/images/' + encodeURIComponent(i.imageFile)
        }
      })
      this.oldImages = resp
      this.waiting = false
    }, response => {
      this.error = 'Failed to get images!'
      this.waiting = false
    })

    this.$http.get(xHTTPx + '/get_audios').then(response => {
      var resp = response.body
      this.audios = resp.map(function(i){
        return i.audioName
      })
    }, response => {
      this.error = 'Failed to get audios!'
    })

    this.windowWidth = window.innerWidth
    window.addEventListener('resize', this.handleResize)
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.handleResize)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.main-container {
  margin-top: 15px;
  padding-top: 10px;
}

.images-container {
  width: 100%;
}

.picture-block {
  margin-bottom: 0px;
}

.image-container {
  display: inline-block;
  margin-left: 10px;
  margin-right: 10px;
  overflow: hidden;
  position: relative;
  border: 1px solid rgba(10, 10, 10, 0.1);
  border-radius: 5px;
  box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1);
  cursor: pointer;
}

.image-options {
  display: inline-block;
}

.my-image {
  width: 100%;
  margin: auto;
  position: absolute;
  top: 0px;
  bottom: 0px;
}

.percentage {
  text-align: center;
}

.upload-button {
  margin: 10px;
}
</style>
