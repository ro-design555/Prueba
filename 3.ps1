# ============================================================
# CONFIGURACIÓN
# ============================================================

# >>> PEGA AQUÍ TU PAGE ACCESS TOKEN <<<
$pageToken = "EAAV3FGQ49RcBSrpJRWMkE2e1nXwRfA2B17krpuGF8w1eY2Gj3mlc0itCON1vil8ZCXKuvRr0ctM9GO0tqRC5xzTENfeL4jeyrQtlsVsb0dI0hUSX5jZBVp2oqavDdZAY8keEmyie9rCZA5vygMhu0ZAyZCZB7OdunEHeX805Ver2oPEtmvukOzbb80oDT4YOKUkM8hQwza5SP4FRRjFedZBVBI2XxVNaINJiBcNp1puAQyi1sIJWYsIZCxTcAlZBmS2OjAcIsGvsuDvhEZD"

# ID de la página MiNeocio
$pageId = "1409465942241201"

# ID del destinatario
$recipient = "28770859835885047"

# Archivo
$file = "Wi-Fi-PASS.txt"

# Versión de Graph API
$apiVersion = "v20.0"


# ============================================================
# 1. COMPROBAR TOKEN
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  1. COMPROBANDO PAGE ACCESS TOKEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {

    $url = "https://graph.facebook.com/$apiVersion/$pageId"
    $url = $url + "?fields=id,name"
    $url = $url + "&access_token=$pageToken"

    $pageInfo = Invoke-RestMethod `
        -Uri $url `
        -Method Get

    Write-Host "TOKEN CORRECTO" -ForegroundColor Green
    Write-Host ""
    Write-Host "Page ID : $($pageInfo.id)"
    Write-Host "Nombre  : $($pageInfo.name)"
    Write-Host ""

}
catch {

    Write-Host "ERROR AL VALIDAR EL TOKEN" -ForegroundColor Red
    Write-Host ""

    Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow

    exit
}


# ============================================================
# 2. COMPROBAR ARCHIVO
# ============================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  2. COMPROBANDO ARCHIVO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $file)) {

    Write-Host "ERROR: El archivo no existe:" -ForegroundColor Red
    Write-Host $file -ForegroundColor Yellow

    exit
}

$fileInfo = Get-Item $file

Write-Host "Archivo encontrado." -ForegroundColor Green
Write-Host ""
Write-Host "Nombre : $($fileInfo.Name)"
Write-Host "Ruta   : $($fileInfo.FullName)"
Write-Host "Tamaño : $($fileInfo.Length) bytes"
Write-Host ""


# ============================================================
# 3. ENVIAR MENSAJE DE PRUEBA
# ============================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  3. ENVIANDO MENSAJE DE PRUEBA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testMessage = "Prueba desde PowerShell - MiNeocio"

$body = @{
    recipient = @{
        id = $recipient
    }
    message = @{
        text = $testMessage
    }
} | ConvertTo-Json -Depth 5


try {

    $url = "https://graph.facebook.com/$apiVersion/$pageId/messages"
    $url = $url + "?access_token=$pageToken"

    $response = Invoke-RestMethod `
        -Uri $url `
        -Method Post `
        -ContentType "application/json" `
        -Body $body

    Write-Host "MENSAJE ENVIADO CORRECTAMENTE" -ForegroundColor Green
    Write-Host ""
    Write-Host "Recipient ID : $($response.recipient_id)"
    Write-Host "Message ID   : $($response.message_id)"
    Write-Host ""

}
catch {

    Write-Host "NO SE PUDO ENVIAR EL MENSAJE" -ForegroundColor Red
    Write-Host ""

    Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow

    exit
}


# ============================================================
# 4. LEER PEDIDO.TXT
# ============================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  4. LEYENDO PEDIDO.TXT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {

    $fileContent = Get-Content `
        -Path $file `
        -Raw `
        -Encoding UTF8

    Write-Host "Archivo leído correctamente." -ForegroundColor Green
    Write-Host "Caracteres: $($fileContent.Length)"
    Write-Host ""

}
catch {

    Write-Host "ERROR AL LEER EL ARCHIVO" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow

    exit
}


# ========================================
# 5. LEYENDO Y ENVIANDO CONTENIDO DEL TXT
# ========================================

try {

    # Leer el archivo como UTF-8
    $fileContent = [System.IO.File]::ReadAllText(
        $file,
        [System.Text.Encoding]::UTF8
    )

    Write-Host "Archivo leído correctamente."
    Write-Host "Caracteres: $($fileContent.Length)"

    # Crear objeto del mensaje
    $messageObject = @{
        recipient = @{
            id = $recipient
        }
        message = @{
            text = $fileContent
        }
    }

    # Convertir a JSON
    $jsonBody = $messageObject | ConvertTo-Json -Depth 5

    # Convertir explícitamente el JSON a bytes UTF-8
    $utf8Body = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

    # URL
    $url = "https://graph.facebook.com/$apiVersion/$pageId/messages"
    $url = $url + "?access_token=$pageToken"

    # Enviar
    $responseFile = Invoke-RestMethod `
        -Uri $url `
        -Method Post `
        -ContentType "application/json; charset=utf-8" `
        -Body $utf8Body

    Write-Host ""
    Write-Host "CONTENIDO ENVIADO CORRECTAMENTE" -ForegroundColor Green
    Write-Host ""
    Write-Host "Message ID: $($responseFile.message_id)"
    Write-Host "Recipient ID: $($responseFile.recipient_id)"
}
catch {

    Write-Host ""
    Write-Host "NO SE PUDO ENVIAR EL CONTENIDO" -ForegroundColor Red
    Write-Host ""

    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message
    }
    else {
        Write-Host $_.Exception.Message
    }
}


# ============================================================
# FINAL
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  PROCESO FINALIZADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
