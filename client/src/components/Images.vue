<template>
  <div class="container main-container">
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
    </div>
    <div v-else>
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>

      <div v-if="images" class="images-container">
        <div class="image-container" :style="{'width': imageSize+'px', 'height': imageSize+'px'}" v-for="(image, i) in images" @click="playImage(i)">
          <img class="my-image" :src="image.url" />
        </div>
      </div>

      <div class="has-text-centered" v-if="uploading">
        <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
      </div>
      <div v-else class="file upload-button">
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
      uploading: false
    }
  },
  computed: {
    images () {
      var images = this.$store.state.images.images
      if(!images){
        return null
      }
      return images.map(function(image){
        return {
          name: image,
          url: xHTTPx + '/images/' + encodeURIComponent(image)
        }
      })
    },
    imageSize () {
      return this.windowWidth > 670 ? 200 : this.windowWidth / 4
    }
  },
  methods: {
    playImage (index) {
      this.$store.commit('images/shuffleImages', index)
      this.$router.push('/')
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      var file = files[0]

      var formData = new FormData()
      formData.append('file', file)

      this.uploading = true
      this.$http.post(xHTTPx + '/upload_image', formData).then(response => {
        var resp = response.body
        this.$store.commit('images/addImage', resp.filename)
        this.uploading = false
        this.error = ''
      }, response => {
        this.error = 'Failed to upload image!'
        this.uploading = false
      })
    },
    handleResize () {
      this.windowWidth = window.innerWidth
    }
  },
  mounted () {
    this.waiting = true
    this.$http.get(xHTTPx + '/get_images').then(response => {
      var resp = response.body
      this.$store.commit('images/setImages', resp)
      this.waiting = false
    }, response => {
      this.error = 'Failed to get images!'
      this.waiting = false
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
}

.images-container {
  width: 100%;
}

.image-container {
  height: 200px;
  width: 200px;
  display: inline-block;
  margin: 10px;
  overflow: hidden;
  position: relative;
  border: 1px solid rgba(10, 10, 10, 0.1);
  border-radius: 5px;
  box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1);
  cursor: pointer;
}

.my-image {
  width: 100%;
  margin: auto;
  position: absolute;
  top: 0px;
  bottom: 0px;
}

.upload-button {
  margin: 10px;
}
</style>
