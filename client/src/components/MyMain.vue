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
      <div class="image-container" @click="toggle">
        <img id="myImage" v-show="!imageLoading" :src="imageSource" @load="imageLoaded" class="img">
        <svg width="100%" :viewBox="viewBox" class="svg" xmlns="http://www.w3.org/2000/svg" version="1.1">
          <path :d=path fill="#37C64E"></path>
        </svg>
      </div>

      <div class="has-text-centered" v-if="imageLoading">
        <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
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
      imageLoading: true,
      playing: false,
      minutes: 1,
      seconds: 0,
      currentSecond: 0,
      timer: null,
      ticking: null,
      tada: null
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
      return xHTTPx + '/images/' + encodeURIComponent(image)
    },
    totalSeconds () {
      return this.minutes * 60 + this.seconds + 0.1
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
      var img = document.getElementById('myImage')
      this.imageLoading = false
      this.$nextTick(function(){
        this.imageWidth = img.clientWidth
        this.imageHeight = img.clientHeight
      })
    },
    play () {
      if(this.currentSecond >= this.totalSeconds){
        this.currentSecond = 0
      }
      var vm = this
      vm.playing = true
      vm.ticking.play()
      vm.timer = setInterval(vm.count, 100)
    },
    pause () {
      clearInterval(this.timer)
      this.playing = false
      this.ticking.pause()
    },
    toggle () {
      if(this.playing){
        this.pause()
      }else{
        this.play()
      }
    },
    clear () {
      this.currentSecond = this.totalSeconds
    },
    count () {
      this.currentSecond += 0.1
      if(this.currentSecond >= this.totalSeconds) {
        clearInterval(this.timer)
        this.playing = false
        this.ticking.pause()
        this.tada.play()
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
        this.ticking.pause()
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
    this.tada = new Audio('static/tada.mp3')
    this.ticking = new Audio('static/ticking.mp3')
    this.ticking.addEventListener('ended', function() {
      this.currentTime = 0;
      this.play();
    }, false)

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
  },
  beforeDestroy () {
    if(this.playing){
      clearInterval(this.timer)
      this.ticking.pause()
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
  z-index: 10;
}
</style>
