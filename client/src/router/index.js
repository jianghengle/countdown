import Vue from 'vue'
import Router from 'vue-router'
import MyMain from '@/components/MyMain'
import Images from '@/components/Images'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MyMain',
      component: MyMain
    },
    {
      path: '/images',
      name: 'Images',
      component: Images
    },
  ]
})
