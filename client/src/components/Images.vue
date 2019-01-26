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
        <div class="image-container" v-for="(image, i) in images" @click="playImage(i)">
          <img class="my-image" :src="image.url" />
        </div>
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
          url: xHTTPx + '/download_image/' + encodeURIComponent(image)
        }
      })
    },
  },
  methods: {
    playImage (index) {
      this.$store.commit('images/shuffleImages', index)
      this.$router.push('/')
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
</style>
