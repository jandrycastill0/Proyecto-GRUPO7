SubProceso Encabezado(titulo, hora, modo, clima)
    Escribir "=============== SISTEMA INTELIGENTE UTMACH ===============";
    Escribir "Pantalla: ", titulo, " | Hora: ", hora, ":00";
    Segun modo Hacer
        1:
            Escribir "Modo: Automatico";
        2:
            Escribir "Modo: Ahorro";
        3:
            Escribir "Modo: Seguridad";
        4:
            Escribir "Modo: Mantenimiento";
    FinSegun
    Segun clima Hacer
        1:
            Escribir "Clima simulado: Despejado";
        2:
            Escribir "Clima simulado: Nublado";
        3:
            Escribir "Clima simulado: Lluvia";
        4:
            Escribir "Clima simulado: Tormenta";
    FinSegun
FinSubProceso

SubProceso MenuPrincipal(hora, modo, clima)
    Encabezado("Menu principal", hora, modo, clima);
    Escribir "1.Panel  2.Simular  3.App sensores";
    Escribir "4.Mantenimiento  5.Estadisticas  0.Salir";
    Escribir "Seleccione opcion:";
FinSubProceso

SubProceso Pausa
    Escribir "Presione una tecla para continuar...";
    Esperar Tecla;
FinSubProceso

Funcion luz <- SensorLDR(hora, clima, ajusteLDR)
    Definir luz Como Real;
    Si hora >= 6 Y hora <= 17 Entonces
        Si hora <= 12 Entonces
            luz <- 150 + hora * 62;
        SiNo
            luz <- 900 - (hora - 12) * 95;
        FinSi
    SiNo
        luz <- 75;
    FinSi
    Segun clima Hacer
        2:
            luz <- luz * 0.65;
        3:
            luz <- luz * 0.50;
        4:
            luz <- luz * 0.35;
    FinSegun
    luz <- luz + ajusteLDR;
    Si luz < 0 Entonces
        luz <- 0;
    FinSi
FinFuncion

Funcion personas <- FlujoPersonas(hora, zona, extra)
    Definir personas Como Entero;
    personas <- 5;
    Si hora >= 7 Y hora <= 9 Entonces
        personas <- 55;
    FinSi
    Si hora >= 10 Y hora <= 13 Entonces
        personas <- 42;
    FinSi
    Si hora >= 16 Y hora <= 22 Entonces
        personas <- 48;
    FinSi
    Si zona = 1 Entonces
        personas <- personas + 18;
    FinSi
    personas <- personas + extra + Aleatorio(0, 12);
    Si personas < 0 Entonces
        personas <- 0;
    FinSi
FinFuncion

Funcion pir <- SensorPIR(personas, forzarPIR)
    Definir pir Como Entero;
    Si forzarPIR = 1 Entonces
        pir <- 95;
    SiNo
        Si forzarPIR = 2 Entonces
            pir <- 0;
        SiNo
            pir <- personas;
            Si pir > 100 Entonces
                pir <- 100;
            FinSi
        FinSi
    FinSi
FinFuncion

Funcion brillo <- CalcularBrillo(luz, pir, modo, umbralLDR, umbralPIR, zona, fallas)
    Definir brillo Como Real;
    Definir oscuro, activo, zonaAlta Como Logico;
    oscuro <- luz < umbralLDR;
    activo <- pir >= umbralPIR;
    zonaAlta <- zona = 1;
    brillo <- 0;
    Si modo <> 4 Entonces
        Si oscuro Entonces
            Si activo Entonces
                Segun modo Hacer
                    1:
                        brillo <- 55 + pir * 0.25;
                    2:
                        brillo <- 35 + pir * 0.12;
                    3:
                        brillo <- 70 + pir * 0.18;
                FinSegun
            SiNo
                brillo <- 18;
            FinSi
        FinSi
        Si zonaAlta Y oscuro Y activo Entonces
            brillo <- brillo + 10;
        FinSi
        Si fallas >= 3 Entonces
            brillo <- brillo + 5;
        FinSi
    FinSi
    Si brillo > 100 Entonces
        brillo <- 100;
    FinSi
FinFuncion

Funcion falla <- RiesgoFalla(clima, horasAlto, pir)
    Definir falla, n Como Entero;
    falla <- 0;
    n <- Aleatorio(1, 100);
    Si clima = 3 Y n > 90 Entonces
        falla <- 1;
    FinSi
    Si clima = 4 Y n > 82 Entonces
        falla <- 2;
    FinSi
    Si horasAlto >= 3 Y n > 84 Entonces
        falla <- 3;
    FinSi
    Si pir > 94 Y n > 88 Entonces
        falla <- 4;
    FinSi
FinFuncion

Funcion consumo <- ConsumoHora(luminarias, watts, brillo, fallas)
    Definir consumo Como Real;
    Definir operativas Como Entero;
    operativas <- luminarias - fallas;
    Si operativas < 0 Entonces
        operativas <- 0;
    FinSi
    consumo <- (operativas * watts * (brillo / 100)) / 1000;
FinFuncion

Funcion porcentaje <- ReglaTres(total, parte)
    Definir porcentaje Como Real;
    Si total <= 0 Entonces
        porcentaje <- 0;
    SiNo
        porcentaje <- (parte * 100) / total;
    FinSi
FinFuncion

Funcion ahorro <- CalcularAhorro(base, real)
    Definir ahorro Como Real;
    ahorro <- 100 - ReglaTres(base, real);
    Si ahorro < 0 Entonces
        ahorro <- 0;
    FinSi
FinFuncion

Funcion estado <- CalcularEstado(fallas, fallaSensor, ahorro, pir)
    Definir estado Como Entero;
    Si fallas >= 5 O fallaSensor > 0 Entonces
        estado <- 3;
    SiNo
        Si fallas >= 2 O ahorro < 20 O pir > 95 Entonces
            estado <- 2;
        SiNo
            estado <- 1;
        FinSi
    FinSi
FinFuncion

Funcion texto <- TextoEstado(op)
    Definir texto Como Cadena;
    Segun op Hacer
        1:
            texto <- "Pendiente";
        2:
            texto <- "Asignado";
        3:
            texto <- "En reparacion";
        4:
            texto <- "Verificado";
        5:
            texto <- "Resuelto";
        De Otro Modo:
            texto <- "Pendiente";
    FinSegun
FinFuncion

SubProceso MensajeModo(modo)
    Segun modo Hacer
        1:
            Escribir "Automatico: usa LDR y PIR; equilibra seguridad y ahorro.";
        2:
            Escribir "Ahorro: baja brillo, reduce consumo y aumenta ahorro.";
        3:
            Escribir "Seguridad: prioriza brillo alto; consume mas, pero ilumina mejor.";
        4:
            Escribir "Mantenimiento: brillo 0; evita activar luces durante revision.";
    FinSegun
FinSubProceso

SubProceso SincronizarEstados(datos, estados Por Referencia, detalle Por Referencia, total)
    Definir i Como Entero;
    Para i <- 1 Hasta total Hacer
        Si datos[i, 3] > 0 Y estados[i] = "Resuelto" Entonces
            estados[i] <- "Pendiente";
            detalle[i] <- "Incidencia pendiente";
        FinSi
        Si datos[i, 3] = 0 Entonces
            estados[i] <- "Resuelto";
            detalle[i] <- "Sin novedades";
        FinSi
    FinPara
FinSubProceso

SubProceso ActualizarFacultad(i, datos Por Referencia, alertas Por Referencia, decisiones Por Referencia, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP)
    Definir luz, brillo, consumo, base, ahorro Como Real;
    Definir personas, pir, fallaSensor Como Entero;
    luz <- SensorLDR(hora, clima, ajusteLDR);
    personas <- FlujoPersonas(hora, datos[i, 4], 0);
    Si i = eventoFacultad Entonces
        personas <- personas + extraP;
    FinSi
    pir <- SensorPIR(personas, forzarPIR);
    brillo <- CalcularBrillo(luz, pir, modo, umbralLDR, umbralPIR, datos[i, 4], datos[i, 3]);
    Si brillo >= 90 Entonces
        datos[i, 12] <- datos[i, 12] + 1;
    SiNo
        datos[i, 12] <- 0;
    FinSi
    fallaSensor <- RiesgoFalla(clima, datos[i, 12], pir);
    Si fallaSensor > 0 Y datos[i, 3] < datos[i, 1] Entonces
        datos[i, 3] <- datos[i, 3] + 1;
    FinSi
    consumo <- ConsumoHora(datos[i, 1], datos[i, 2], brillo, datos[i, 3]);
    base <- (datos[i, 1] * datos[i, 2]) / 1000;
    ahorro <- CalcularAhorro(base, consumo);
    datos[i, 5] <- luz;
    datos[i, 6] <- personas;
    datos[i, 7] <- pir;
    datos[i, 8] <- brillo;
    datos[i, 9] <- consumo;
    datos[i, 10] <- ahorro;
    datos[i, 13] <- fallaSensor;
    datos[i, 14] <- base;
    datos[i, 15] <- datos[i, 1] - datos[i, 3];
    datos[i, 11] <- CalcularEstado(datos[i, 3], fallaSensor, ahorro, pir);
    Segun datos[i, 11] Hacer
        1:
            alertas[i] <- "Sin alerta";
            decisiones[i] <- "Normal: brillo ajustado segun luz y flujo.";
        2:
            alertas[i] <- "Preventiva";
            decisiones[i] <- "Revisar consumo, flujo o incidencias.";
        3:
            alertas[i] <- "Urgente";
            decisiones[i] <- "Critico: generar orden de mantenimiento.";
    FinSegun
    Si luz > umbralLDR Y pir < umbralPIR Entonces
        decisiones[i] <- "Ahorro activo: luz suficiente y bajo flujo.";
    FinSi
FinSubProceso

SubProceso RecorrerCampus(datos Por Referencia, alertas Por Referencia, decisiones Por Referencia, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP, total)
    Definir i Como Entero;
    Para i <- 1 Hasta total Hacer
        ActualizarFacultad(i, datos, alertas, decisiones, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP);
    FinPara
FinSubProceso

SubProceso Panel(datos, nombres, alertas, decisiones, total, hora, modo, clima)
    Definir i Como Entero;
    Encabezado("Panel en vivo", hora, modo, clima);
    Escribir "Matriz: 1 lum, 2 watts, 3 fallas, 4 zona, 5 LDR, 6 personas, 7 PIR, 8 brillo, 9 consumo, 10 ahorro, 11 estado.";
    Para i <- 1 Hasta total Hacer
        Escribir i, ". ", nombres[i];
        Escribir "LDR:", datos[i, 5], " | Personas:", datos[i, 6], " | PIR:", datos[i, 7], "% | Brillo:", datos[i, 8], "%";
        Escribir "Consumo:", datos[i, 9], " kWh | Ahorro:", datos[i, 10], "% | Fallas:", datos[i, 3], " | Alerta:", alertas[i];
        Segun datos[i, 11] Hacer
            1:
                Escribir "Estado: NORMAL";
            2:
                Escribir "Estado: PREVENTIVO";
            3:
                Escribir "Estado: CRITICO";
        FinSegun
        Escribir "Decision: ", decisiones[i];
        Escribir "--------------------------------------------------------------";
    FinPara
FinSubProceso

SubProceso ElegirPasos(pasos Por Referencia)
    Definir op Como Entero;
    Escribir "Tiempo: 1)2h | 2)6h | 3)8h | 4)12h | 5)24h";
    Leer op;
    Mientras op < 1 O op > 5 Hacer
        Escribir "Ingrese opcion valida:";
        Leer op;
    FinMientras
    Segun op Hacer
        1:
            pasos <- 2;
        2:
            pasos <- 6;
        3:
            pasos <- 8;
        4:
            pasos <- 12;
        5:
            pasos <- 24;
    FinSegun
FinSubProceso

SubProceso Simulacion(datos Por Referencia, alertas Por Referencia, decisiones Por Referencia, estados Por Referencia, detalle Por Referencia, nombres, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, total)
    Definir op, pasos, p, i, eventoFacultad, extraP Como Entero;
    Definir horaLocal, climaLocal Como Entero;
    Definir consumoPaso, consumoTotal, promPIR, promPersonas Como Real;
    Repetir
        Encabezado("Simulacion", hora, modo, clima);
        Escribir "1.Predeterminado  2.Clima y hora  3.Evento personas  0.Volver";
        Leer op;
        pasos <- 0;
        eventoFacultad <- 0;
        extraP <- 0;
        horaLocal <- hora;
        climaLocal <- clima;
        Segun op Hacer
            1:
                climaLocal <- 1;
                horaLocal <- 7;
                ElegirPasos(pasos);
            2:
                Escribir "Clima afecta la luz que lee el LDR: 1 Despejado | 2 Nublado | 3 Lluvia | 4 Tormenta";
                Leer climaLocal;
                Mientras climaLocal < 1 O climaLocal > 4 Hacer
                    Escribir "Clima invalido:";
                    Leer climaLocal;
                FinMientras
                Escribir "Hora inicial 0 a 23:";
                Leer horaLocal;
                Mientras horaLocal < 0 O horaLocal > 23 Hacer
                    Escribir "Hora invalida:";
                    Leer horaLocal;
                FinMientras
                ElegirPasos(pasos);
            3:
                Escribir "Facultad 1-5:";
                Leer eventoFacultad;
                Si eventoFacultad < 1 O eventoFacultad > total Entonces
                    eventoFacultad <- 1;
                FinSi
                Escribir "Personas adicionales:";
                Leer extraP;
                Si extraP < 0 Entonces
                    extraP <- 0;
                FinSi
                Escribir "Hora inicial 0 a 23:";
                Leer horaLocal;
                ElegirPasos(pasos);
        FinSegun
        Si pasos > 0 Entonces
            consumoTotal <- 0;
            promPIR <- 0;
            promPersonas <- 0;
            Para p <- 1 Hasta pasos Hacer
                horaLocal <- horaLocal + 1;
                Si horaLocal = 24 Entonces
                    horaLocal <- 0;
                FinSi
                RecorrerCampus(datos, alertas, decisiones, horaLocal, modo, climaLocal, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP, total);
                SincronizarEstados(datos, estados, detalle, total);
                consumoPaso <- 0;
                Para i <- 1 Hasta total Hacer
                    consumoPaso <- consumoPaso + datos[i, 9];
                    promPIR <- promPIR + datos[i, 7];
                    promPersonas <- promPersonas + datos[i, 6];
                FinPara
                consumoTotal <- consumoTotal + consumoPaso;
                Escribir "Hora ", horaLocal, " | Personas prom:", promPersonas / (p * total), " | PIR prom:", promPIR / (p * total), "% | Consumo:", consumoPaso;
            FinPara
            Escribir "Consumo acumulado: ", consumoTotal, " kWh";
            Escribir "Clima fuerte, brillo alto o PIR alto pueden generar nuevas fallas.";
            Pausa;
        FinSi
    Hasta Que op = 0
FinSubProceso

SubProceso Estadisticas(datos, nombres, total, hora, modo, clima)
    Definir i, normales, preventivos, criticos, facMayor Como Entero;
    Definir base, consumoReal, ahorroKwh, ahorroPorc, potencia, mayorConsumo, ahorroProm, promPersonas, menorConsumo Como Real;
    base <- 0;
    consumoReal <- 0;
    potencia <- 0;
    normales <- 0;
    preventivos <- 0;
    criticos <- 0;
    mayorConsumo <- -1;
    menorConsumo <- 99999;
    facMayor <- 1;
    ahorroProm <- 0;
    promPersonas <- 0;
    Encabezado("Estadisticas", hora, modo, clima);
    Para i <- 1 Hasta total Hacer
        base <- base + datos[i, 14];
        consumoReal <- consumoReal + datos[i, 9];
        potencia <- potencia + datos[i, 1] * datos[i, 2];
        ahorroProm <- ahorroProm + datos[i, 10];
        promPersonas <- promPersonas + datos[i, 6];
        Si datos[i, 9] > mayorConsumo Entonces
            mayorConsumo <- datos[i, 9];
            facMayor <- i;
        FinSi
        Si datos[i, 9] < menorConsumo Entonces
            menorConsumo <- datos[i, 9];
        FinSi
        Segun datos[i, 11] Hacer
            1:
                normales <- normales + 1;
            2:
                preventivos <- preventivos + 1;
            3:
                criticos <- criticos + 1;
        FinSegun
    FinPara
    ahorroKwh <- base - consumoReal;
    ahorroPorc <- CalcularAhorro(base, consumoReal);
    ahorroProm <- ahorroProm / total;
    promPersonas <- promPersonas / total;
    Escribir "Normales:", normales, " | Preventivos:", preventivos, " | Criticos:", criticos;
    Escribir "Prom. personas:", promPersonas, " | Prom. ahorro:", ahorroProm, "% | Menor consumo:", menorConsumo;
    Escribir "Potencia:", potencia, " W | Corriente:", potencia / 120, " A";
    Escribir "Consumo base:", base, " | Consumo inteligente:", consumoReal;
    Escribir "Ahorro:", ahorroPorc, "% | Ahorro mensual:", ahorroKwh * 12 * 30, " kWh";
    Escribir "Ahorro $:", ahorroKwh * 12 * 30 * 0.10, " | CO2 evitado:", ahorroKwh * 12 * 30 * 0.42, " kg";
    Escribir "Mayor consumo: ", nombres[facMayor], " con ", mayorConsumo, " kWh";
    Si criticos > 0 Entonces
        Escribir "Diagnostico: prioridad alta para mantenimiento.";
    SiNo
        Si preventivos > 0 Entonces
            Escribir "Diagnostico: revisar estados preventivos.";
        SiNo
            Escribir "Diagnostico: campus estable.";
        FinSi
    FinSi
FinSubProceso

SubProceso Mantenimiento(datos Por Referencia, nombres, estados Por Referencia, detalle Por Referencia, total)
    Definir op, fac, nuevo, corregidas, i Como Entero;
    Definir texto Como Cadena;
    Repetir
        SincronizarEstados(datos, estados, detalle, total);
        Encabezado("Mantenimiento", 0, 1, 1);
        Escribir "1.Ver reportes  2.Escribir falla  3.Cambiar estado/corregir  0.Volver";
        Leer op;
        Segun op Hacer
            1:
                Para i <- 1 Hasta total Hacer
                    Escribir i, ". ", nombres[i], " | Fallas pendientes: ", datos[i, 3], " | Estado: ", estados[i];
                    Escribir "Detalle: ", detalle[i];
                FinPara
            2:
                Escribir "Facultad 1-5:";
                Leer fac;
                Si fac >= 1 Y fac <= total Entonces
                    Escribir "Describa la falla observada:";
                    Leer texto;
                    datos[fac, 3] <- datos[fac, 3] + 1;
                    estados[fac] <- "Pendiente";
                    detalle[fac] <- texto;
                FinSi
            3:
                Escribir "Facultad 1-5:";
                Leer fac;
                Escribir "1 Pendiente | 2 Asignado | 3 En reparacion | 4 Verificado | 5 Resuelto";
                Leer nuevo;
                Si fac >= 1 Y fac <= total Entonces
                    estados[fac] <- TextoEstado(nuevo);
                    Si nuevo = 4 O nuevo = 5 Entonces
                        Escribir "Fallas pendientes actuales: ", datos[fac, 3];
                        Escribir "Cuantas fallas fueron corregidas?";
                        Leer corregidas;
                        Si corregidas < 0 Entonces
                            corregidas <- 0;
                        FinSi
                        Si corregidas > datos[fac, 3] Entonces
                            corregidas <- datos[fac, 3];
                        FinSi
                        datos[fac, 3] <- datos[fac, 3] - corregidas;
                        Si datos[fac, 3] = 0 Entonces
                            estados[fac] <- "Resuelto";
                            detalle[fac] <- "Sin novedades";
                            datos[fac, 13] <- 0;
                            Escribir "Todas las fallas corregidas. Estado: Resuelto.";
                        SiNo
                            estados[fac] <- "En reparacion";
                            Escribir "Corregidas: ", corregidas, ". Pendientes: ", datos[fac, 3];
                        FinSi
                    SiNo
                        Escribir "Estado cambiado. Las fallas siguen pendientes.";
                    FinSi
                FinSi
        FinSegun
    Hasta Que op = 0
FinSubProceso

Algoritmo SimuladorIluminacionUTMACH
    Definir datos Como Real;
    Definir nombres, decisiones, estados, detalle, alertas Como Cadena;
    Definir total, opcion, i, j, opApp, anterior Como Entero;
    Definir hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR Como Entero;
    Definir salir Como Logico;
    Dimension datos[6, 16];
    Dimension nombres[6];
    Dimension decisiones[6];
    Dimension estados[6];
    Dimension detalle[6];
    Dimension alertas[6];
    total <- 5;
    nombres[1] <- "Facultad de Ciencias Agropecuarias";
    nombres[2] <- "Facultad de Ciencias Empresariales";
    nombres[3] <- "Facultad de Ciencias Quimicas y de la Salud";
    nombres[4] <- "Facultad de Ciencias Sociales";
    nombres[5] <- "Facultad de Ingenieria Civil";
    Para i <- 1 Hasta total Hacer
        Para j <- 1 Hasta 15 Hacer
            datos[i, j] <- 0;
        FinPara
        estados[i] <- "Resuelto";
        detalle[i] <- "Sin novedades";
        alertas[i] <- "Sin alerta";
        decisiones[i] <- "Sin evaluar";
    FinPara
    datos[1, 1] <- 70;
    datos[1, 2] <- 80;
    datos[1, 4] <- 2;
    datos[2, 1] <- 95;
    datos[2, 2] <- 80;
    datos[2, 4] <- 1;
    datos[3, 1] <- 85;
    datos[3, 2] <- 80;
    datos[3, 3] <- 1;
    datos[3, 4] <- 2;
    datos[4, 1] <- 90;
    datos[4, 2] <- 80;
    datos[4, 4] <- 1;
    datos[5, 1] <- 100;
    datos[5, 2] <- 80;
    datos[5, 4] <- 1;
    SincronizarEstados(datos, estados, detalle, total);
    salir <- Falso;
    hora <- 18;
    modo <- 1;
    clima <- 1;
    umbralLDR <- 500;
    umbralPIR <- 45;
    forzarPIR <- 3;
    ajusteLDR <- 0;
    RecorrerCampus(datos, alertas, decisiones, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);
    Repetir
        MenuPrincipal(hora, modo, clima);
        Leer opcion;
        Segun opcion Hacer
            1:
                RecorrerCampus(datos, alertas, decisiones, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);
                Panel(datos, nombres, alertas, decisiones, total, hora, modo, clima);
            2:
                Simulacion(datos, alertas, decisiones, estados, detalle, nombres, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, total);
            3:
                Repetir
                    Encabezado("Aplicacion sensores", hora, modo, clima);
                    Escribir "1.Modo 2.Umbral LDR 3.Umbral PIR 4.Forzar PIR 5.Ajuste LDR 0.Volver";
                    Leer opApp;
                    Segun opApp Hacer
                        1:
                            Escribir "El modo cambia la estrategia antes de recalcular brillo y consumo.";
                            Escribir "1 Auto | 2 Ahorro | 3 Seguridad | 4 Mantenimiento";
                            Leer modo;
                            MensajeModo(modo);
                        2:
                            anterior <- umbralLDR;
                            Escribir "LDR actual: ", umbralLDR, ". Recomendado: 300 a 700. Mayor=prende antes.";
                            Escribir "Nuevo umbral LDR:";
                            Leer umbralLDR;
                            Si umbralLDR > anterior Entonces
                                Escribir "Subio: activa con mas claridad; puede bajar ahorro.";
                            SiNo
                                Escribir "Bajo/igual: espera mas oscuridad; puede subir ahorro.";
                            FinSi
                        3:
                            anterior <- umbralPIR;
                            Escribir "PIR actual: ", umbralPIR, ". Rango: 0 a 100. Mayor=exige mas personas.";
                            Escribir "Nuevo umbral PIR:";
                            Leer umbralPIR;
                            Si umbralPIR > anterior Entonces
                                Escribir "Subio: menos activaciones, menor consumo.";
                            SiNo
                                Escribir "Bajo/igual: mas activaciones, mayor consumo.";
                            FinSi
                        4:
                            Escribir "1 Siempre detecta | 2 Nunca detecta | 3 Automatico";
                            Leer forzarPIR;
                            Segun forzarPIR Hacer
                                1:
                                    Escribir "Presencia alta: sube brillo y consumo.";
                                2:
                                    Escribir "Ausencia: baja brillo y sube ahorro.";
                                3:
                                    Escribir "Automatico: usa flujo de personas.";
                            FinSegun
                        5:
                            anterior <- ajusteLDR;
                            Escribir "Ajuste LDR actual: ", ajusteLDR, ". -300 a 300. Negativo=sombra, positivo=claridad.";
                            Escribir "Nuevo ajuste LDR:";
                            Leer ajusteLDR;
                            Si ajusteLDR < anterior Entonces
                                Escribir "Mas sombra: tendera a encender mas.";
                            SiNo
                                Escribir "Mas claridad/igual: tendera a ahorrar.";
                            FinSi
                    FinSegun
                    RecorrerCampus(datos, alertas, decisiones, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);
                    SincronizarEstados(datos, estados, detalle, total);
                    Escribir "Cambio aplicado. Revise panel: brillo, consumo, ahorro y alertas se actualizaron.";
                Hasta Que opApp = 0
            4:
                Mantenimiento(datos, nombres, estados, detalle, total);
            5:
                Estadisticas(datos, nombres, total, hora, modo, clima);
            0:
                salir <- Verdadero;
            De Otro Modo:
                Escribir "Opcion no valida.";
        FinSegun
        Si salir = Falso Entonces
            Pausa;
            Limpiar Pantalla;
        FinSi
    Hasta Que salir = Verdadero
    Escribir "Sistema cerrado correctamente.";
FinAlgoritmo
