import Vue from 'vue'
import Router from 'vue-router'
import MyMain from '@/components/MyMain'
import Images from '@/components/Images'
import Audios from '@/components/Audios'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MyMain',
      component: MyMain
    },
    {
      path: '/start/:imageName',
      name: 'MyMainStart',
      component: MyMain
    },
    {
      path: '/images',
      name: 'Images',
      component: Images
    },
    {
      path: '/audios',
      name: 'Audios',
      component: Audios
    },
  ]
})
