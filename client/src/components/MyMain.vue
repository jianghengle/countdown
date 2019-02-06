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
      <div class="image-container" @click="toggle" :style="{'height': imageHeight+'px'}">
        <img id="myImage" v-show="!imageLoading" :src="imageSource" @load="imageLoaded" class="img">
        <svg width="100%" height="100%" :viewBox="viewBox" class="svg" xmlns="http://www.w3.org/2000/svg" version="1.1">
          <path :d=path :fill="fillColor"></path>
        </svg>
      </div>

      <div class="has-text-centered is-size-5 has-text-weight-bold image-text">
        <transition name="bounce">
          <div v-if="currentSecond >= totalSeconds">{{imageText}}</div>
        </transition>
      </div>

      <div class="has-text-centered" v-if="imageLoading">
        <v-icon name="spinner" class="icon is-medium fa-spin"></v-icon>
      </div>
    </div>
  </div>
</template>

<script>

var green = [35, 209, 90]
var red = [255, 0, 0]
var step = [(red[0] - green[0]) / 360, (red[1] - green[1]) / 360, (red[2] - green[2]) / 360]

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
      images: null,
    }
  },
  computed: {
    imageSource () {
      if(!this.images)
        return ''
      var image = this.images[this.index]
      return xHTTPx + '/images/' + encodeURIComponent(image.imageFile)
    },
    endingAudio () {
      if(!this.images)
        return null
      var image = this.images[this.index]
      var src = xHTTPx + '/audios/' + encodeURIComponent(image.audioFile)
      return new Audio(src)
    },
    imageText () {
      if(!this.images)
        return null
      return this.images[this.index].imageName
    },
    totalSeconds () {
      return this.minutes * 60 + this.seconds + 0.1
    },
    degree () {
      var step = 360 / this.totalSeconds
      return this.currentSecond * step
    },
    fillColor () {
      var r = Math.floor(this.degree * step[0] + green[0])
      var g = Math.floor(this.degree * step[1] + green[1])
      var b = Math.floor(this.degree * step[2] + green[2])
      return 'rgb(' + r + ',' + g + ','+ b +')'
    },
    path () {
      if(this.degree !== null && this.degree >= 0 && this.degree < 360 && this.imageWidth && this.imageHeight){
        var d = this.degree
        if(d == 0){
          d = 0.001
        }
        var r = d / 180 * Math.PI
        var x = 100 * Math.sin(r)
        var y = 100 - 100 * Math.cos(r)
        var a = d > 180 ? '0' : '1'
        return 'M100,100 v-100 a100 100 0 ' + a + ' 0 ' + x + ' ' + y + ' Z'
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
    },
    routeImageName () {
      if(this.$route.params.imageName){
        return atob(this.$route.params.imageName)
      }
      return ''
    },
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
        if(this.endingAudio){
          this.endingAudio.pause()
        }
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
        this.endingAudio.play()
      }
    },
    back () {
      if(this.endingAudio){
        this.endingAudio.pause()
      }
      if(this.currentSecond == 0){
        if(this.index == 0){
          this.index = this.images.length - 1
        }else{
          this.index -= 1
        }
      }else{
        this.currentSecond = 0
      }
    },
    next () {
      if(this.endingAudio){
        this.endingAudio.pause()
      }
      if(this.currentSecond >= this.totalSeconds){
        this.currentSecond = 0
        if(this.index == this.images.length - 1){
          this.index = 0
        }else{
          this.index += 1
        }
      }else{
        this.currentSecond = this.totalSeconds
        clearInterval(this.timer)
        this.playing = false
        this.ticking.pause()
        this.endingAudio.play()
      }
    },
    shuffle (a) {
      var j, x, i;
      for (i = a.length - 1; i > 0; i--) {
        j = Math.floor(Math.random() * (i + 1));
        x = a[i];
        a[i] = a[j];
        a[j] = x;
      }
    }
  },
  mounted () {
    this.ticking = new Audio('static/ticking.mp3')
    this.ticking.addEventListener('ended', function() {
      this.currentTime = 0;
      this.play();
    }, false)

    
    this.waiting = true
    this.$http.get(xHTTPx + '/get_images_with_audios').then(response => {
      var images = response.body
      this.shuffle(images)
      if(this.routeImageName){
        var index = -1
        for(var i=0;i<images.length;i++){
          if(images[i].imageName == this.routeImageName){
            index = i
            break
          }
        }
        if(index != -1){
          var firstImage = images[index]
          images.splice(index, 1)
          images.unshift(firstImage)
        }
      }
      this.images = images
      this.waiting = false
    }, response => {
      this.error = 'Failed to get images!'
      this.waiting = false
    })
    
  },
  beforeDestroy () {
    if(this.playing){
      clearInterval(this.timer)
      this.ticking.pause()
    }
    if(this.endingAudio){
      this.endingAudio.pause()
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
  border: 1px solid rgba(10, 10, 10, 0.1);
  border-radius: 5px;
  box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1);
  cursor: pointer;
  overflow: hidden;
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

.image-text {
  min-height: 100px;
}

.bounce-enter-active {
  animation: bounce-in 2s;
}

@keyframes bounce-in {
  0% {
    transform: scale(0);
  }
  50% {
    transform: scale(2);
  }
  100% {
    transform: scale(1);
  }
}
</style>
