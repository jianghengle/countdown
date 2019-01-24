<template>
  <div class="container">
    <div>
      <input type="number" v-model="degree">
      <input type="number" v-model="w">
      <input type="number" v-model="h">
    </div>
    <div class="image-container">
      <svg width="100%" :viewBox="viewBox">
        <path :d=path fill="#37C64E" />
        Sorry, your browser does not support inline SVG.
      </svg>
    </div>
  </div>
</template>

<script>

export default {
  name: 'my-main',
  data () {
    return {
      degree: 10,
      w: 400,
      h: 300
    }
  },
  computed: {
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
      if(!this.path || !this.w || !this.h)
        return '0 0 0 0'
      var w = this.w
      var h = this.h
      while(w > 100 || h > 100){
        w /= 2
        h /= 2
      }
      var mx = 100 - (w / 2)
      var my = 100 - (h / 2)
      return '' + mx + ' ' + my + ' ' + w + ' ' + h
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.image-container {
  padding: 5px;
}
</style>
