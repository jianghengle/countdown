// initial state
export const state = {
  images: null,
}

// mutations
export const mutations = {

  setImages (state, images) {
    state.images = images
  },

  addImage (state, image) {
    state.images.push(image)
  },

  shuffleImages (state, index) {
    var arr = state.images.slice()
    var head = []
    if(index != undefined){
      head = [arr[index]]
      arr.splice(index, 1)
    }
    shuffle(arr)
    state.images = head.concat(arr)
  }
}

export default {
  namespaced: true,
  state,
  mutations
}

function shuffle(a) {
  var j, x, i;
  for (i = a.length - 1; i > 0; i--) {
    j = Math.floor(Math.random() * (i + 1));
    x = a[i];
    a[i] = a[j];
    a[j] = x;
  }
}