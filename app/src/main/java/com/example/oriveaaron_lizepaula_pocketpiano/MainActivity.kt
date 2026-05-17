package com.example.oriveaaron_lizepaula_pocketpiano

import android.media.SoundPool
import android.os.Bundle
import android.view.MotionEvent
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    // SoundPool: permite tocar varias notas a la vez (multitouch)
    private lateinit var soundPool: SoundPool

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // SoundPool con 10 sonidos simultáneos
        soundPool = SoundPool.Builder().setMaxStreams(10).build()

        //Teclas Principales
        setupTecla(R.id.C2, R.raw.do3)
        setupTecla(R.id.D2, R.raw.re3)
        setupTecla(R.id.E2, R.raw.mi3)
        setupTecla(R.id.F2, R.raw.fa3)
        setupTecla(R.id.G2, R.raw.sol3)
        setupTecla(R.id.A2, R.raw.la3)
        setupTecla(R.id.B2, R.raw.si3)
        setupTecla(R.id.C3, R.raw.do4)
        setupTecla(R.id.D3, R.raw.re4)
        setupTecla(R.id.E3, R.raw.mi4)
        setupTecla(R.id.F3, R.raw.fa4)
        setupTecla(R.id.G3, R.raw.sol4)
        setupTecla(R.id.A3, R.raw.la4)
        setupTecla(R.id.B3, R.raw.si4)
        setupTecla(R.id.C4, R.raw.do5)

        // Teclas NEGRAS
        setupTecla(R.id.C2b, R.raw.dos3)
        setupTecla(R.id.D2b, R.raw.res3)
        setupTecla(R.id.F2b, R.raw.fas3)
        setupTecla(R.id.G2b, R.raw.sols3)
        setupTecla(R.id.A2b, R.raw.las3)
        setupTecla(R.id.C3b, R.raw.dos4)
        setupTecla(R.id.D3b, R.raw.res4)
        setupTecla(R.id.F3b, R.raw.fas4)
        setupTecla(R.id.G3b, R.raw.sols4)
        setupTecla(R.id.A3b, R.raw.las4)
    }

    // Carga el sonido y le pone el listener táctil al botón
    private fun setupTecla(botonId: Int, sonidoId: Int) {
        val sonido = soundPool.load(this, sonidoId, 1)
        val boton  = findViewById<android.widget.ImageButton>(botonId)

        boton.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                // Dedo abajo: reproducir sonido y marcar como presionado
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN -> {
                    soundPool.play(sonido, 1f, 1f, 1, 0, 1f)
                    view.isPressed = true
                    view.performClick()
                }
                // Dedo arriba: quitar el estado presionado
                MotionEvent.ACTION_UP, MotionEvent.ACTION_POINTER_UP, MotionEvent.ACTION_CANCEL -> {
                    view.isPressed = false
                }
            }
            true
        }
    }

    // Liberar memoria de audio al cerrar la app
    override fun onDestroy() {
        super.onDestroy()
        soundPool.release()
    }
}

