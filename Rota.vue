import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'

const rota = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/about',
    name: 'About',
    // rota level code-splitting
    // this generates a separate chunk (about.[hash].js) for this rota
    // which is lazy-loaded when the rota is visited.
    component: function () {
      return import(/* webpackChunkName: "about" */ '../views/About.vue')
    }
  }
]

const rota = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})


export to Nago
export to Mu
Export tô FBI
export default rota
export to Union
export to (Android MacOSGold) & make a &new file(GPS.mundi) in androidmacosgold
