import Vue from 'vue'
import Router from 'vue-router'
import MyMain from '@/components/MyMain'
import Docs from '@/components/Docs'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MyMain',
      component: MyMain
    },
    {
      path: '/docs',
      name: 'Docs',
      component: Docs
    },
  ]
})
