<template>
  <div>
    <nav class="navbar has-shadow">
      <div class="container">
        <div class="navbar-brand container level is-mobile">
          <router-link class="navbar-item is-size-4 has-text-weight-bold has-text-black level-left" :to="'/'">
            Count Down
          </router-link>
          <div class="level-right">
            <router-link class="navbar-item" :class="{'active-route': routePath=='/images'}" :to="'/images'">
              <v-icon name="image" scale="1.2" />
            </router-link>
            <router-link class="navbar-item" :class="{'active-route': routePath=='/audios'}" :to="'/audios'">
              <v-icon name="music" scale="1.2" />
            </router-link>
          </div>
        </div>
      </div>
    </nav>
  </div>
</template>

<script>
export default {
  name: 'my-header',
  data () {
    return {
      menuActive: false
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    routePath () {
      return this.$route.path
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.active-route {
  color: #4571e1;
}

</style>
