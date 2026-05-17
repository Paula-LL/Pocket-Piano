# =====================================================
# Generador de notas - Rango C3 a C5 (más agradable)
# Nombres en español: do3, re3, mi3... igual que las imágenes
# =====================================================

$outputDir  = "app\src\main\res\raw"
$sampleRate = 44100
$duration   = 2.5
$volume     = 0.75

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Notas en ORDEN MUSICAL (Do, Re, Mi...) con nombre en español
# Rango octava 3 y 4 (más parecido a un piano real de demostración)
$notes = [ordered]@{
    # --- Teclas BLANCAS octava 3 ---
    "do3"  = 130.81   # Do
    "re3"  = 146.83   # Re
    "mi3"  = 164.81   # Mi
    "fa3"  = 174.61   # Fa
    "sol3" = 196.00   # Sol
    "la3"  = 220.00   # La
    "si3"  = 246.94   # Si
    # --- Teclas BLANCAS octava 4 ---
    "do4"  = 261.63   # Do (Do central - la nota más reconocible del piano)
    "re4"  = 293.66   # Re
    "mi4"  = 329.63   # Mi
    "fa4"  = 349.23   # Fa
    "sol4" = 392.00   # Sol
    "la4"  = 440.00   # La (el La estándar de afinación)
    "si4"  = 493.88   # Si
    "do5"  = 523.25   # Do (octava 5)
    # --- Teclas NEGRAS octava 3 (sostenidos) ---
    "dos3" = 138.59   # Do# (entre Do y Re)
    "res3" = 155.56   # Re#
    "fas3" = 185.00   # Fa#
    "sols3"= 207.65   # Sol#
    "las3" = 233.08   # La#
    # --- Teclas NEGRAS octava 4 ---
    "dos4" = 277.18   # Do#
    "res4" = 311.13   # Re#
    "fas4" = 369.99   # Fa#
    "sols4"= 415.30   # Sol#
    "las4" = 466.16   # La#
}

function Generate-Note {
    param([string]$name, [double]$freq)

    $N       = [int]($sampleRate * $duration)
    $samples = New-Object double[] $N

    # Armónicos con decaimiento individual (imita cuerdas de piano)
    $harmonics = @(
        @{ m = 1.0; a = 1.00; decay = 1.8  }
        @{ m = 2.0; a = 0.60; decay = 2.5  }
        @{ m = 3.0; a = 0.35; decay = 3.5  }
        @{ m = 4.0; a = 0.20; decay = 5.0  }
        @{ m = 5.0; a = 0.12; decay = 7.0  }
        @{ m = 6.0; a = 0.07; decay = 9.0  }
        @{ m = 7.0; a = 0.04; decay = 12.0 }
    )

    # Inharmonicidad (las cuerdas reales no vibran en múltiplos exactos)
    $B = 0.0001 * ($freq / 130.0)

    for ($i = 0; $i -lt $N; $i++) {
        $t = $i / $sampleRate
        $s = 0.0
        foreach ($h in $harmonics) {
            $fn  = $h.m * $freq * [Math]::Sqrt(1 + $B * $h.m * $h.m)
            $env = [Math]::Exp(-$h.decay * $t)
            $s  += $h.a * $env * [Math]::Sin(2 * [Math]::PI * $fn * $t)
        }
        # Ataque de 5ms (golpe del martillo)
        $attack      = [Math]::Min(1.0, $t / 0.005)
        $samples[$i] = $s * $attack
    }

    # Escribir WAV
    $path   = "$outputDir\$name.wav"
    $stream = [System.IO.File]::Create($path)
    $writer = New-Object System.IO.BinaryWriter($stream)

    $dataBytes = $N * 2
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
    $writer.Write([int32](36 + $dataBytes))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
    $writer.Write([int32]16)
    $writer.Write([int16]1)
    $writer.Write([int16]1)
    $writer.Write([int32]$sampleRate)
    $writer.Write([int32]($sampleRate * 2))
    $writer.Write([int16]2)
    $writer.Write([int16]16)
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
    $writer.Write([int32]$dataBytes)

    foreach ($s in $samples) {
        $pcm = [int]($s * $volume * 32767)
        if ($pcm -gt  32767) { $pcm =  32767 }
        if ($pcm -lt -32768) { $pcm = -32768 }
        $writer.Write([int16]$pcm)
    }

    $writer.Close()
    $stream.Close()
    Write-Host "OK  $name.wav  ($([Math]::Round($freq,2)) Hz)"
}

Write-Host "Generando notas en orden musical..." -ForegroundColor Cyan
foreach ($n in $notes.GetEnumerator()) {
    Generate-Note -name $n.Key -freq $n.Value
}
Write-Host "`nListo! $($notes.Count) notas en '$outputDir'" -ForegroundColor Green
