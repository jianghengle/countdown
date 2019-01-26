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

      <div>
        <div class="field is-grouped is-grouped-centered">
          <p class="control">
            <span class="select">
              <select v-model="minutes">
                <option v-bind:value="0">0 min</option>
                <option v-bind:value="1">1 min</option>
                <option v-bind:value="2">2 mins</option>
                <option v-bind:value="3">3 mins</option>
                <option v-bind:value="4">4 mins</option>
                <option v-bind:value="5">5 mins</option>
              </select>
            </span>
          </p>
          <p class="control">
            <span class="select">
              <select v-model="seconds">
                <option v-bind:value="0">0 sec</option>
                <option v-bind:value="10">10 secs</option>
                <option v-bind:value="20">20 secs</option>
                <option v-bind:value="30">30 secs</option>
                <option v-bind:value="40">40 secs</option>
                <option v-bind:value="50">50 secs</option>
              </select>
            </span>
          </p>
          <p class="control" v-if="!playing">
            <a class="button" @click="play">
              <v-icon name="play"/>
            </a>
          </p>
          <p class="control" v-if="playing">
            <a class="button" @click="pause">
              <v-icon name="pause"/>
            </a>
          </p>
          <p class="control">
            <a class="button" @click="back">
              <v-icon name="step-backward"/>
            </a>
          </p>
          <p class="control">
            <a class="button" @click="next">
              <v-icon name="step-forward"/>
            </a>
          </p>
        </div>

      </div>
      <div class="image-container">
        <img v-show="!imageLoading" :src="imageSource" @load="imageLoaded" class="img">
        <svg width="100%" :viewBox="viewBox" class="svg">
          <path :d=path fill="#37C64E" />
          Sorry, your browser does not support inline SVG.
        </svg>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'my-main',
  data () {
    return {
      waiting: false,
      error: '',
      index: 0,
      imageWidth: 0,
      imageHeight: 0,
      imageLoading: false,
      playing: false,
      minutes: 2,
      seconds: 0,
      currentSecond: 0,
      timer: null
    }
  },
  computed: {
    images () {
      return this.$store.state.images.images
    },
    imageSource () {
      if(!this.images)
        return ''
      var image = this.images[this.index]
      return xHTTPx + '/download_image/' + encodeURIComponent(image)
    },
    totalSeconds () {
      return this.minutes * 60 + this.seconds
    },
    degree () {
      var step = 360 / this.totalSeconds
      return this.currentSecond * step
    },
    path () {
      if(this.degree !== null && this.degree >= 0 && this.degree < 360){
        var d = this.degree
        if(d == 0){
          d = 0.001
        }
        var r = d / 180 * Math.PI
        var x = 100 * Math.sin(r)
        var y = 100 - 100 * Math.cos(r)
        var a = d > 180 ? '0' : '1'
        return 'M100,100 v-100, a100 100 0 ' + a + ' 0 ' + x + ' ' + y + ' Z' 
      }
      return ''
    },
    viewBox () {
      if(!this.path || !this.imageWidth || !this.imageHeight)
        return '0 0 0 0'
      var w = this.imageWidth
      var h = this.imageHeight
      while(w > 100 || h > 100){
        w /= 2
        h /= 2
      }
      var mx = 100 - (w / 2)
      var my = 100 - (h / 2)
      return '' + mx + ' ' + my + ' ' + w + ' ' + h
    }
  },
  watch: {
    imageSource: function (val) {
      if(val){
        this.imageLoading = true
        this.imageWidth = 0
        this.imageHeight = 0
      }
    }
  },
  methods: {
    imageLoaded (event) {
      var img = event.path[0]
      this.imageWidth = img.width
      this.imageHeight = img.height
      this.$nextTick(function(){
        this.imageLoading = false
      })
    },
    play () {
      if(this.currentSecond >= this.totalSeconds){
        this.currentSecond = 0
      }
      var vm = this
      vm.playing = true
      vm.timer = setInterval(vm.count, 1000)
    },
    pause () {
      clearInterval(this.timer)
      this.playing = false
    },
    count () {
      this.currentSecond += 1
      if(this.currentSecond >= this.totalSeconds) {
        clearInterval(this.timer)
        this.playing = false
      }
    },
    back () {
      this.currentSecond = 0
      if(!this.playing){
        if(this.index == 0){
          this.index = this.images.length - 1
        }else{
          this.index -= 1
        }
      }
    },
    next () {
      if(this.playing){
        clearInterval(this.timer)
        this.playing = false
      }
      this.currentSecond = 0
      if(this.index == this.images.length - 1){
        this.index = 0
      }else{
        this.index += 1
      }
    }
  },
  mounted () {
    if(this.images == null) {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_images').then(response => {
        var resp = response.body
        this.$store.commit('images/setImages', resp)
        this.$store.commit('images/shuffleImages')
        this.waiting = false
      }, response => {
        this.error = 'Failed to get images!'
        this.waiting = false
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.main-container {
  margin-top: 15px;
}

.image-container {
  margin-top: 10px;
  position: relative;
}

.img {
  width: 100%;
}

.svg {
  position: absolute;
  top: 0px;
  left: 0px;
}
</style>
