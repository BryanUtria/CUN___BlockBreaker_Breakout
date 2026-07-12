return {
    -- Nivel 1 (Mayor dificultad: 6 filas, escudos irrompibles y más fuertes)
    {
        filas = 6,
        columnas = 8,
        -- 0: vacío, 1: normal, 2: fuerte, 3: irrompible
        matriz = {
            {2, 2, 2, 2, 2, 2, 2, 2},
            {1, 1, 1, 1, 1, 1, 1, 1},
            {1, 3, 1, 2, 2, 1, 3, 1},
            {1, 1, 1, 1, 1, 1, 1, 1},
            {0, 2, 1, 3, 3, 1, 2, 0},
            {1, 1, 1, 1, 1, 1, 1, 1}
        }
    },
    -- Nivel 2 (Mayor dificultad: 7 filas, estructura de fortaleza, muchos irrompibles)
    {
        filas = 7,
        columnas = 10,
        matriz = {
            {3, 2, 2, 3, 2, 2, 3, 2, 2, 3},
            {2, 2, 1, 1, 1, 1, 1, 1, 2, 2},
            {1, 1, 3, 1, 2, 2, 1, 3, 1, 1},
            {1, 1, 1, 1, 3, 3, 1, 1, 1, 1},
            {1, 2, 1, 3, 1, 1, 3, 1, 2, 1},
            {2, 2, 1, 1, 1, 1, 1, 1, 2, 2},
            {3, 1, 1, 2, 2, 2, 2, 1, 1, 3}
        }
    }
}
