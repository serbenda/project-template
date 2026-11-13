// Punto de entrada. Normas: datos externos con textContent (nunca innerHTML),
// fallos de red gestionados y sin secretos en el código.
"use strict";

const estado = document.getElementById("estado");

/**
 * Descarga JSON con tiempo máximo y errores controlados.
 * @param {string} url
 * @param {number} [ms=10000]
 */
async function obtenerJSON(url, ms = 10000) {
  const control = new AbortController();
  const temporizador = setTimeout(() => control.abort(), ms);
  try {
    const respuesta = await fetch(url, { signal: control.signal });
    if (!respuesta.ok) throw new Error(`HTTP ${respuesta.status}`);
    return await respuesta.json();
  } finally {
    clearTimeout(temporizador);
  }
}

async function iniciar() {
  try {
    // const datos = await obtenerJSON("https://api.ejemplo.es/datos");
    estado.textContent = "Listo.";
  } catch (error) {
    console.error(error);
    estado.textContent = "No se han podido cargar los datos. Inténtalo más tarde.";
  }
}

iniciar();
