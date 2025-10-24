<template>
  <div class="not-found">
    <div class="error-code">404</div>
    <div class="message">¡Ups! Página no encontrada</div>
    <p class="description">
      Parece que la página que buscas no existe o fue movida.
    </p>
    <button @click="goHome" class="home-btn">Volver al inicio</button>
  </div>
</template>

<script>
export default {
  name: 'NotFound',
  methods: {
    goHome() {
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
.not-found {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background: radial-gradient(circle at 50% 30%, #020202, #121212);
  color: #fff;
  text-align: center;
  font-family: 'Montserrat', sans-serif;
  animation: fadeIn 0.8s ease;
}

.error-code {
  font-size: 10rem;
  font-weight: 800;
  background: linear-gradient(45deg, #ff4d4d, #f00505);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: glow 2s ease-in-out infinite alternate;
}

.message {
  font-size: 2rem;
  margin-top: 1rem;
  font-weight: 500;
}

.description {
  color: #bbb;
  max-width: 400px;
  margin-top: 0.5rem;
  margin-bottom: 2rem;
}

.home-btn {
  background: linear-gradient(45deg, #3700cf, #201492);
  border: none;
  color: white;
  padding: 0.8rem 1.6rem;
  border-radius: 30px;
  cursor: pointer;
  font-weight: 600;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.home-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 15px rgba(255, 77, 77, 0.4);
}



@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
