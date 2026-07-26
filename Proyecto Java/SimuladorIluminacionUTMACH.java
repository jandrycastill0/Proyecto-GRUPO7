import java.util.Random;
import java.util.Scanner;
public class SimuladorIluminacionUTMACH {

    static Scanner teclado = new Scanner(System.in);
    static Random random = new Random();
    static double[][] datos = new double[6][16];
    static String[] nombres = new String[6];
    static String[] decisiones = new String[6];
    static String[] estados = new String[6];
    static String[] detalle = new String[6];
    static String[] alertas = new String[6];

    public static void main(String[] args) {
        int total = 5;
        nombres[1] = "Facultad de Ciencias Agropecuarias";
        nombres[2] = "Facultad de Ciencias Empresariales";
        nombres[3] = "Facultad de Ciencias Quimicas y de la Salud";
        nombres[4] = "Facultad de Ciencias Sociales";
        nombres[5] = "Facultad de Ingenieria Civil";

        for (int i = 1; i <= total; i++) {
            for (int j = 1; j <= 15; j++) {
                datos[i][j] = 0;
            }
            estados[i] = "Resuelto";
            detalle[i] = "Sin novedades";
            alertas[i] = "Sin alerta";
            decisiones[i] = "Sin evaluar";
        }

        datos[1][1] = 70;  datos[1][2] = 80;  datos[1][4] = 2;
        datos[2][1] = 95;  datos[2][2] = 80;  datos[2][4] = 1;
        datos[3][1] = 85;  datos[3][2] = 80;  datos[3][3] = 1; datos[3][4] = 2;
        datos[4][1] = 90;  datos[4][2] = 80;  datos[4][4] = 1;
        datos[5][1] = 100; datos[5][2] = 80;  datos[5][4] = 1;

        sincronizarEstados(total);

        boolean salir = false;
        int hora = 18;
        int modo = 1;
        int clima = 1;
        int umbralLDR = 500;
        int umbralPIR = 45;
        int forzarPIR = 3;
        int ajusteLDR = 0;

        recorrerCampus(hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);

        int opcion;
        do {
            menuPrincipal(hora, modo, clima);
            opcion = leerEntero();
            switch (opcion) {
                case 1: {
                    recorrerCampus(hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);
                    panel(total, hora, modo, clima);
                    break;
                }
                case 2: {
                    simulacion(hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, total);
                    break;
                }
                case 3: {
                    int opApp;
                    do {
                        encabezado("Aplicacion sensores", hora, modo, clima);
                        System.out.println("1.Modo 2.Umbral LDR 3.Umbral PIR 4.Forzar PIR 5.Ajuste LDR 0.Volver");
                        opApp = leerEntero();
                        switch (opApp) {
                            case 1: {
                                System.out.println("El modo cambia la estrategia antes de recalcular brillo y consumo.");
                                System.out.println("1 Auto | 2 Ahorro | 3 Seguridad | 4 Mantenimiento");
                                modo = leerEntero();
                                mensajeModo(modo);
                                break;
                            }
                            case 2: {
                                int anterior = umbralLDR;
                                System.out.println("LDR actual: " + umbralLDR + ". Recomendado: 300 a 700. Mayor=prende antes.");
                                System.out.println("Nuevo umbral LDR:");
                                umbralLDR = leerEntero();
                                if (umbralLDR > anterior) {
                                    System.out.println("Subio: activa con mas claridad; puede bajar ahorro.");
                                } else {
                                    System.out.println("Bajo/igual: espera mas oscuridad; puede subir ahorro.");
                                }
                                break;
                            }
                            case 3: {
                                int anterior = umbralPIR;
                                System.out.println("PIR actual: " + umbralPIR + ". Rango: 0 a 100. Mayor=exige mas personas.");
                                System.out.println("Nuevo umbral PIR:");
                                umbralPIR = leerEntero();
                                if (umbralPIR > anterior) {
                                    System.out.println("Subio: menos activaciones, menor consumo.");
                                } else {
                                    System.out.println("Bajo/igual: mas activaciones, mayor consumo.");
                                }
                                break;
                            }
                            case 4: {
                                System.out.println("1 Siempre detecta | 2 Nunca detecta | 3 Automatico");
                                forzarPIR = leerEntero();
                                switch (forzarPIR) {
                                    case 1: System.out.println("Presencia alta: sube brillo y consumo."); break;
                                    case 2: System.out.println("Ausencia: baja brillo y sube ahorro."); break;
                                    case 3: System.out.println("Automatico: usa flujo de personas."); break;
                                }
                                break;
                            }
                            case 5: {
                                int anterior = ajusteLDR;
                                System.out.println("Ajuste LDR actual: " + ajusteLDR + ". -300 a 300. Negativo=sombra, positivo=claridad.");
                                System.out.println("Nuevo ajuste LDR:");
                                ajusteLDR = leerEntero();
                                if (ajusteLDR < anterior) {
                                    System.out.println("Mas sombra: tendera a encender mas.");
                                } else {
                                    System.out.println("Mas claridad/igual: tendera a ahorrar.");
                                }
                                break;
                            }
                        }
                        recorrerCampus(hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, 0, 0, total);
                        sincronizarEstados(total);
                        System.out.println("Cambio aplicado. Revise panel: brillo, consumo, ahorro y alertas se actualizaron.");
                    } while (opApp != 0);
                    break;
                }
                case 4: {
                    mantenimiento(total);
                    break;
                }
                case 5: {
                    estadisticas(total, hora, modo, clima);
                    break;
                }
                case 0: {
                    salir = true;
                    break;
                }
                default: {
                    System.out.println("Opcion no valida.");
                }
            }
            if (!salir) {
                pausa();
                limpiarPantalla();
            }
        } while (!salir);

        System.out.println("Sistema cerrado correctamente.");
        teclado.close();
    }

    static int leerEntero() {
        try {
            return Integer.parseInt(teclado.nextLine().trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /** Equivalente a Aleatorio(min,max) de PSeInt: entero aleatorio entre
     *  min y max, ambos incluidos. */
    static int aleatorio(int min, int max) {
        return min + random.nextInt(max - min + 1);
    }

    static void limpiarPantalla() {
        System.out.print("\033[H\033[2J");
        System.out.flush();
    }

    static void encabezado(String titulo, int hora, int modo, int clima) {
        System.out.println("=============== SISTEMA INTELIGENTE UTMACH ===============");
        System.out.println("Pantalla: " + titulo + " | Hora: " + hora + ":00");
        switch (modo) {
            case 1: System.out.println("Modo: Automatico"); break;
            case 2: System.out.println("Modo: Ahorro"); break;
            case 3: System.out.println("Modo: Seguridad"); break;
            case 4: System.out.println("Modo: Mantenimiento"); break;
        }
        switch (clima) {
            case 1: System.out.println("Clima simulado: Despejado"); break;
            case 2: System.out.println("Clima simulado: Nublado"); break;
            case 3: System.out.println("Clima simulado: Lluvia"); break;
            case 4: System.out.println("Clima simulado: Tormenta"); break;
        }
    }

    static void menuPrincipal(int hora, int modo, int clima) {
        encabezado("Menu principal", hora, modo, clima);
        System.out.println("1.Panel  2.Simular  3.App sensores");
        System.out.println("4.Mantenimiento  5.Estadisticas  0.Salir");
        System.out.println("Seleccione opcion:");
    }

    static void pausa() {
        System.out.println("Presione una tecla para continuar...");
        teclado.nextLine(); // Equivalente practico de "Esperar Tecla"
    }

    static void mensajeModo(int modo) {
        switch (modo) {
            case 1: System.out.println("Automatico: usa LDR y PIR; equilibra seguridad y ahorro."); break;
            case 2: System.out.println("Ahorro: baja brillo, reduce consumo y aumenta ahorro."); break;
            case 3: System.out.println("Seguridad: prioriza brillo alto; consume mas, pero ilumina mejor."); break;
            case 4: System.out.println("Mantenimiento: brillo 0; evita activar luces durante revision."); break;
        }
    }
    static double sensorLDR(int hora, int clima, int ajusteLDR) {
        double luz;
        if (hora >= 6 && hora <= 17) {
            if (hora <= 12) {
                luz = 150 + hora * 62;
            } else {
                luz = 900 - (hora - 12) * 95;
            }
        } else {
            luz = 75;
        }
        switch (clima) {
            case 2: luz = luz * 0.65; break;
            case 3: luz = luz * 0.50; break;
            case 4: luz = luz * 0.35; break;
        }
        luz = luz + ajusteLDR;
        if (luz < 0) {
            luz = 0;
        }
        return luz;
    }

    static int flujoPersonas(int hora, int zona, int extra) {
        int personas = 5;
        if (hora >= 7 && hora <= 9) {
            personas = 55;
        }
        if (hora >= 10 && hora <= 13) {
            personas = 42;
        }
        if (hora >= 16 && hora <= 22) {
            personas = 48;
        }
        if (zona == 1) {
            personas = personas + 18;
        }
        personas = personas + extra + aleatorio(0, 12);
        if (personas < 0) {
            personas = 0;
        }
        return personas;
    }

    static int sensorPIR(int personas, int forzarPIR) {
        int pir;
        if (forzarPIR == 1) {
            pir = 95;
        } else if (forzarPIR == 2) {
            pir = 0;
        } else {
            pir = personas;
            if (pir > 100) {
                pir = 100;
            }
        }
        return pir;
    }

    static double calcularBrillo(double luz, int pir, int modo, int umbralLDR, int umbralPIR, double zona, double fallas) {
        boolean oscuro = luz < umbralLDR;
        boolean activo = pir >= umbralPIR;
        boolean zonaAlta = zona == 1;
        double brillo = 0;
        if (modo != 4) {
            if (oscuro) {
                if (activo) {
                    switch (modo) {
                        case 1: brillo = 55 + pir * 0.25; break;
                        case 2: brillo = 35 + pir * 0.12; break;
                        case 3: brillo = 70 + pir * 0.18; break;
                    }
                } else {
                    brillo = 18;
                }
            }
            if (zonaAlta && oscuro && activo) {
                brillo = brillo + 10;
            }
            if (fallas >= 3) {
                brillo = brillo + 5;
            }
        }
        if (brillo > 100) {
            brillo = 100;
        }
        return brillo;
    }

    static int riesgoFalla(int clima, double horasAlto, int pir) {
        int falla = 0;
        int n = aleatorio(1, 100);
        if (clima == 3 && n > 90) {
            falla = 1;
        }
        if (clima == 4 && n > 82) {
            falla = 2;
        }
        if (horasAlto >= 3 && n > 84) {
            falla = 3;
        }
        if (pir > 94 && n > 88) {
            falla = 4;
        }
        return falla;
    }

    static double consumoHora(double luminarias, double watts, double brillo, double fallas) {
        double operativas = luminarias - fallas;
        if (operativas < 0) {
            operativas = 0;
        }
        return (operativas * watts * (brillo / 100)) / 1000;
    }

    static double reglaTres(double total, double parte) {
        double porcentaje;
        if (total <= 0) {
            porcentaje = 0;
        } else {
            porcentaje = (parte * 100) / total;
        }
        return porcentaje;
    }

    static double calcularAhorro(double base, double real) {
        double ahorro = 100 - reglaTres(base, real);
        if (ahorro < 0) {
            ahorro = 0;
        }
        return ahorro;
    }

    static int calcularEstado(double fallas, int fallaSensor, double ahorro, int pir) {
        int estado;
        if (fallas >= 5 || fallaSensor > 0) {
            estado = 3;
        } else if (fallas >= 2 || ahorro < 20 || pir > 95) {
            estado = 2;
        } else {
            estado = 1;
        }
        return estado;
    }

    static String textoEstado(int op) {
        String texto;
        switch (op) {
            case 1: texto = "Pendiente"; break;
            case 2: texto = "Asignado"; break;
            case 3: texto = "En reparacion"; break;
            case 4: texto = "Verificado"; break;
            case 5: texto = "Resuelto"; break;
            default: texto = "Pendiente";
        }
        return texto;
    }
    static void sincronizarEstados(int total) {
        for (int i = 1; i <= total; i++) {
            if (datos[i][3] > 0 && estados[i].equals("Resuelto")) {
                estados[i] = "Pendiente";
                detalle[i] = "Incidencia pendiente";
            }
            if (datos[i][3] == 0) {
                estados[i] = "Resuelto";
                detalle[i] = "Sin novedades";
            }
        }
    }

    static void actualizarFacultad(int i, int hora, int modo, int clima, int umbralLDR, int umbralPIR,
                                    int forzarPIR, int ajusteLDR, int eventoFacultad, int extraP) {
        double luz = sensorLDR(hora, clima, ajusteLDR);
        int personas = flujoPersonas(hora, (int) datos[i][4], 0);
        if (i == eventoFacultad) {
            personas = personas + extraP;
        }
        int pir = sensorPIR(personas, forzarPIR);
        double brillo = calcularBrillo(luz, pir, modo, umbralLDR, umbralPIR, datos[i][4], datos[i][3]);
        if (brillo >= 90) {
            datos[i][12] = datos[i][12] + 1;
        } else {
            datos[i][12] = 0;
        }
        int fallaSensor = riesgoFalla(clima, datos[i][12], pir);
        if (fallaSensor > 0 && datos[i][3] < datos[i][1]) {
            datos[i][3] = datos[i][3] + 1;
        }
        double consumo = consumoHora(datos[i][1], datos[i][2], brillo, datos[i][3]);
        double base = (datos[i][1] * datos[i][2]) / 1000;
        double ahorro = calcularAhorro(base, consumo);
        datos[i][5] = luz;
        datos[i][6] = personas;
        datos[i][7] = pir;
        datos[i][8] = brillo;
        datos[i][9] = consumo;
        datos[i][10] = ahorro;
        datos[i][13] = fallaSensor;
        datos[i][14] = base;
        datos[i][15] = datos[i][1] - datos[i][3];
        datos[i][11] = calcularEstado(datos[i][3], fallaSensor, ahorro, pir);
        switch ((int) datos[i][11]) {
            case 1:
                alertas[i] = "Sin alerta";
                decisiones[i] = "Normal: brillo ajustado segun luz y flujo.";
                break;
            case 2:
                alertas[i] = "Preventiva";
                decisiones[i] = "Revisar consumo, flujo o incidencias.";
                break;
            case 3:
                alertas[i] = "Urgente";
                decisiones[i] = "Critico: generar orden de mantenimiento.";
                break;
        }
        if (luz > umbralLDR && pir < umbralPIR) {
            decisiones[i] = "Ahorro activo: luz suficiente y bajo flujo.";
        }
    }

    static void recorrerCampus(int hora, int modo, int clima, int umbralLDR, int umbralPIR, int forzarPIR,
                                int ajusteLDR, int eventoFacultad, int extraP, int total) {
        for (int i = 1; i <= total; i++) {
            actualizarFacultad(i, hora, modo, clima, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP);
        }
    }

    static void panel(int total, int hora, int modo, int clima) {
        encabezado("Panel en vivo", hora, modo, clima);
        System.out.println("Matriz: 1 lum, 2 watts, 3 fallas, 4 zona, 5 LDR, 6 personas, 7 PIR, 8 brillo, 9 consumo, 10 ahorro, 11 estado.");
        for (int i = 1; i <= total; i++) {
            System.out.println(i + ". " + nombres[i]);
            System.out.println("LDR:" + datos[i][5] + " | Personas:" + datos[i][6] + " | PIR:" + datos[i][7] + "% | Brillo:" + datos[i][8] + "%");
            System.out.println("Consumo:" + datos[i][9] + " kWh | Ahorro:" + datos[i][10] + "% | Fallas:" + datos[i][3] + " | Alerta:" + alertas[i]);
            switch ((int) datos[i][11]) {
                case 1: System.out.println("Estado: NORMAL"); break;
                case 2: System.out.println("Estado: PREVENTIVO"); break;
                case 3: System.out.println("Estado: CRITICO"); break;
            }
            System.out.println("Decision: " + decisiones[i]);
            System.out.println("--------------------------------------------------------------");
        }
    }
    static int elegirPasos() {
        System.out.println("Tiempo: 1)2h | 2)6h | 3)8h | 4)12h | 5)24h");
        int op = leerEntero();
        while (op < 1 || op > 5) {
            System.out.println("Ingrese opcion valida:");
            op = leerEntero();
        }
        switch (op) {
            case 1: return 2;
            case 2: return 6;
            case 3: return 8;
            case 4: return 12;
            case 5: return 24;
        }
        return 0;
    }

    static void simulacion(int hora, int modo, int clima, int umbralLDR, int umbralPIR, int forzarPIR,
                            int ajusteLDR, int total) {
        int op;
        do {
            encabezado("Simulacion", hora, modo, clima);
            System.out.println("1.Predeterminado  2.Clima y hora  3.Evento personas  0.Volver");
            op = leerEntero();
            int pasos = 0;
            int eventoFacultad = 0;
            int extraP = 0;
            int horaLocal = hora;
            int climaLocal = clima;
            switch (op) {
                case 1: {
                    climaLocal = 1;
                    horaLocal = 7;
                    pasos = elegirPasos();
                    break;
                }
                case 2: {
                    System.out.println("Clima afecta la luz que lee el LDR: 1 Despejado | 2 Nublado | 3 Lluvia | 4 Tormenta");
                    climaLocal = leerEntero();
                    while (climaLocal < 1 || climaLocal > 4) {
                        System.out.println("Clima invalido:");
                        climaLocal = leerEntero();
                    }
                    System.out.println("Hora inicial 0 a 23:");
                    horaLocal = leerEntero();
                    while (horaLocal < 0 || horaLocal > 23) {
                        System.out.println("Hora invalida:");
                        horaLocal = leerEntero();
                    }
                    pasos = elegirPasos();
                    break;
                }
                case 3: {
                    System.out.println("Facultad 1-5:");
                    eventoFacultad = leerEntero();
                    if (eventoFacultad < 1 || eventoFacultad > total) {
                        eventoFacultad = 1;
                    }
                    System.out.println("Personas adicionales:");
                    extraP = leerEntero();
                    if (extraP < 0) {
                        extraP = 0;
                    }
                    System.out.println("Hora inicial 0 a 23:");
                    horaLocal = leerEntero();
                    pasos = elegirPasos();
                    break;
                }
            }
            if (pasos > 0) {
                double consumoTotal = 0;
                double promPIR = 0;
                double promPersonas = 0;
                for (int p = 1; p <= pasos; p++) {
                    horaLocal = horaLocal + 1;
                    if (horaLocal == 24) {
                        horaLocal = 0;
                    }
                    recorrerCampus(horaLocal, modo, climaLocal, umbralLDR, umbralPIR, forzarPIR, ajusteLDR, eventoFacultad, extraP, total);
                    sincronizarEstados(total);
                    double consumoPaso = 0;
                    for (int i = 1; i <= total; i++) {
                        consumoPaso = consumoPaso + datos[i][9];
                        promPIR = promPIR + datos[i][7];
                        promPersonas = promPersonas + datos[i][6];
                    }
                    consumoTotal = consumoTotal + consumoPaso;
                    System.out.println("Hora " + horaLocal + " | Personas prom:" + (promPersonas / (p * total))
                            + " | PIR prom:" + (promPIR / (p * total)) + "% | Consumo:" + consumoPaso);
                }
                System.out.println("Consumo acumulado: " + consumoTotal + " kWh");
                System.out.println("Clima fuerte, brillo alto o PIR alto pueden generar nuevas fallas.");
                pausa();
            }
        } while (op != 0);
    }

    static void estadisticas(int total, int hora, int modo, int clima) {
        int normales = 0;
        int preventivos = 0;
        int criticos = 0;
        int facMayor = 1;
        double base = 0;
        double consumoReal = 0;
        double potencia = 0;
        double mayorConsumo = -1;
        double menorConsumo = 99999;
        double ahorroProm = 0;
        double promPersonas = 0;

        encabezado("Estadisticas", hora, modo, clima);
        for (int i = 1; i <= total; i++) {
            base = base + datos[i][14];
            consumoReal = consumoReal + datos[i][9];
            potencia = potencia + datos[i][1] * datos[i][2];
            ahorroProm = ahorroProm + datos[i][10];
            promPersonas = promPersonas + datos[i][6];
            if (datos[i][9] > mayorConsumo) {
                mayorConsumo = datos[i][9];
                facMayor = i;
            }
            if (datos[i][9] < menorConsumo) {
                menorConsumo = datos[i][9];
            }
            switch ((int) datos[i][11]) {
                case 1: normales = normales + 1; break;
                case 2: preventivos = preventivos + 1; break;
                case 3: criticos = criticos + 1; break;
            }
        }
        double ahorroKwh = base - consumoReal;
        double ahorroPorc = calcularAhorro(base, consumoReal);
        ahorroProm = ahorroProm / total;
        promPersonas = promPersonas / total;

        System.out.println("Normales:" + normales + " | Preventivos:" + preventivos + " | Criticos:" + criticos);
        System.out.println("Prom. personas:" + promPersonas + " | Prom. ahorro:" + ahorroProm + "% | Menor consumo:" + menorConsumo);
        System.out.println("Potencia:" + potencia + " W | Corriente:" + (potencia / 120) + " A");
        System.out.println("Consumo base:" + base + " | Consumo inteligente:" + consumoReal);
        System.out.println("Ahorro:" + ahorroPorc + "% | Ahorro mensual:" + (ahorroKwh * 12 * 30) + " kWh");
        System.out.println("Ahorro $:" + (ahorroKwh * 12 * 30 * 0.10) + " | CO2 evitado:" + (ahorroKwh * 12 * 30 * 0.42) + " kg");
        System.out.println("Mayor consumo: " + nombres[facMayor] + " con " + mayorConsumo + " kWh");
        if (criticos > 0) {
            System.out.println("Diagnostico: prioridad alta para mantenimiento.");
        } else if (preventivos > 0) {
            System.out.println("Diagnostico: revisar estados preventivos.");
        } else {
            System.out.println("Diagnostico: campus estable.");
        }
    }

    static void mantenimiento(int total) {
        int op;
        do {
            sincronizarEstados(total);
            encabezado("Mantenimiento", 0, 1, 1);
            System.out.println("1.Ver reportes  2.Escribir falla  3.Cambiar estado/corregir  0.Volver");
            op = leerEntero();
            switch (op) {
                case 1: {
                    for (int i = 1; i <= total; i++) {
                        System.out.println(i + ". " + nombres[i] + " | Fallas pendientes: " + datos[i][3] + " | Estado: " + estados[i]);
                        System.out.println("Detalle: " + detalle[i]);
                    }
                    break;
                }
                case 2: {
                    System.out.println("Facultad 1-5:");
                    int fac = leerEntero();
                    if (fac >= 1 && fac <= total) {
                        System.out.println("Describa la falla observada:");
                        String texto = teclado.nextLine();
                        datos[fac][3] = datos[fac][3] + 1;
                        estados[fac] = "Pendiente";
                        detalle[fac] = texto;
                    }
                    break;
                }
                case 3: {
                    System.out.println("Facultad 1-5:");
                    int fac = leerEntero();
                    System.out.println("1 Pendiente | 2 Asignado | 3 En reparacion | 4 Verificado | 5 Resuelto");
                    int nuevo = leerEntero();
                    if (fac >= 1 && fac <= total) {
                        estados[fac] = textoEstado(nuevo);
                        if (nuevo == 4 || nuevo == 5) {
                            System.out.println("Fallas pendientes actuales: " + datos[fac][3]);
                            System.out.println("Cuantas fallas fueron corregidas?");
                            int corregidas = leerEntero();
                            if (corregidas < 0) {
                                corregidas = 0;
                            }
                            if (corregidas > datos[fac][3]) {
                                corregidas = (int) datos[fac][3];
                            }
                            datos[fac][3] = datos[fac][3] - corregidas;
                            if (datos[fac][3] == 0) {
                                estados[fac] = "Resuelto";
                                detalle[fac] = "Sin novedades";
                                datos[fac][13] = 0;
                                System.out.println("Todas las fallas corregidas. Estado: Resuelto.");
                            } else {
                                estados[fac] = "En reparacion";
                                System.out.println("Corregidas: " + corregidas + ". Pendientes: " + datos[fac][3]);
                            }
                        } else {
                            System.out.println("Estado cambiado. Las fallas siguen pendientes.");
                        }
                    }
                    break;
                }
            }
        } while (op != 0);
    }
}