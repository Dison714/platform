// Перевод 9 районных страниц — es. Топонимы остаются на латинице.
export default {
  whichBikeHtml: `<ul>
<li><strong>Circular por la ciudad</strong> (cafés, tiendas, trayectos cortos): una <strong><a href="/es/bikes?category=honda_pcx160">Honda PCX 160</a></strong> o <strong><a href="/es/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — totalmente automática, fácil de aparcar, más que suficiente para carreteras locales llanas.</li>
<li><strong>Colinas / aventura ligera</strong>: una <strong><a href="/es/bikes?category=honda_adv160">Honda ADV 160</a></strong> — mayor altura libre al suelo, también automática, más segura en cuestas que un scooter urbano.</li>
<li><strong>Excursiones largas</strong> por Bali: una <strong><a href="/es/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — motor más potente, más estable a velocidad de carretera, más cómoda en distancias largas.</li>
<li><strong>Pasajero + equipaje</strong> / turismo de varios días: una <strong><a href="/es/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> o <strong><a href="/es/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — motos touring con marchas manuales, pensadas para ir de dos con carga, mejor para motoristas con más experiencia.</li>
</ul>`,
  deliveryDisclaimer: 'Los precios anteriores son orientativos — confirma el coste exacto de la entrega para tus fechas y horarios con nuestro equipo.',
  faqBiggerBikeLinkLabel: "Motos",
  faqMinRental: { q: '¿Hay una duración mínima de alquiler?', a: 'No hay mínimo — solo la tarifa de entrega cambia según la duración del alquiler.' },
  faqIdpQ: (district, prep) => `¿Necesito un permiso de conducir internacional para circular ${prep} ${district}?`,
  faqIdpA: 'Sí, junto con tu carné de tu país — consulta nuestra guía completa:',
  faqIdpLinkLabel: 'Conducir en Bali sin carné: los riesgos reales',
  faqDepositQ: '¿Cuál es vuestra política de depósito y daños?',
  faqDepositA: 'Consulta nuestra guía de depósito y seguridad:',
  faqDepositLinkLabel: 'Artículos sobre depósito y seguridad',
  ctaBody: (district, prep) => `¿Listo para reservar? Escríbenos por WhatsApp tus fechas y el punto de recogida ${prep} ${district}, y confirmaremos tu moto y la hora de entrega.`,
  districts: {
    canggu: {
      name: 'Canggu', prep: 'en',
      h1: 'Alquiler de scooters y motos en Canggu',
      intro: 'Canggu es nuestra zona de entrega más activa — playas de surf, espacios de coworking y beach clubs concentrados en pocos kilómetros cuadrados, con casi cualquier villa u hostal a unos minutos en scooter. Entregamos en cualquier punto de Canggu — Berawa, Batu Bolong, Echo Beach, Pererenan, Tibubeneng — y te preparamos una moto acorde a la distancia que realmente vas a recorrer.',
      seoTitle: 'Alquiler de scooter Canggu, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Canggu con entrega rápida a Berawa, Batu Bolong, Pererenan y Echo Beach. Entrega gratis en alquileres semanales, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 15 días o más · Rp 100.000 para 7–14 días · Rp 150.000 fijo por menos de una semana — en cualquier punto de Canggu.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>15 días o más</strong>.</li>
<li><strong>7–14 días:</strong> tarifa fija de entrega de Rp 100.000, en cualquier punto de Canggu.</li>
<li>Alquileres más cortos (menos de 7 días): tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Canggu.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde nuestro almacén en Kerobokan, a pocos minutos de Canggu.</li>
</ul>
<p>La zona de entrega en Canggu es la misma para toda la zona, incluidos Pererenan y Echo Beach al norte — no hay restricciones especiales.</p>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Las carreteras de Canggu se construyeron para un pueblo de pescadores, no para la cantidad actual de scooters, coches y furgonetas de reparto. Espera atascos reales <strong>entre las 8–10 de la mañana y las 16–19 h</strong>, especialmente en Jalan Raya Canggu, alrededor de Kerobokan y en el Canggu Shortcut que conecta Berawa con Batu Bolong — un tramo estrecho que puede colapsarse en horas punta.</p>
<p>Un scooter sigue siendo la forma más rápida de moverse: puedes esquivar el tráfico lento y aparcar donde un coche simplemente no cabe. El aparcamiento se complica justo antes del atardecer cerca de los principales beach clubs (Batu Bolong / Old Man's, Berawa / Finns) — llega un poco antes si vas para el atardecer.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Canggu, incluyendo Pererenan y Echo Beach?',
      faqA1: 'Sí — la entrega cubre todo Canggu. Gratis desde 15 días, Rp 100.000 para 7–14 días, Rp 150.000 fijo por menos de una semana.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Canggu\" más arriba. Si te quedas sobre todo en Canggu, un scooter es suficiente; para excursiones a Ubud/Uluwatu, una NMAX o ADV es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
      whichBikeExtra: "<p>¿Quieres llegar con estilo, no solo llegar? Las café racer — <strong><a href=\"/es/bikes?group=motorcycle&amp;model=yamaha_xsr\">XSR</a></strong> y <strong><a href=\"/es/bikes?group=motorcycle&amp;model=tvs_ronin225\">Ronin</a></strong> — y los modelos deportivos encajan perfecto en Canggu y Seminyak: ágiles en el tráfico, vistosas en el paseo marítimo y frente a tu café favorito. Si el estilo te importa tanto como la comodidad, esta es tu opción.</p>",
    },
    seminyak: {
      name: 'Seminyak', prep: 'en',
      h1: 'Alquiler de scooters y motos en Seminyak',
      intro: 'Seminyak es la franja exclusiva de beach clubs y boutiques de Bali — una cuadrícula densa de tiendas de diseño, spas y restaurantes entre el Oberoi y la costa. La mayoría de villas y hoteles están a un corto trayecto llano de la playa, y un scooter es la forma más sencilla de moverse entre puntos de atardecer sin buscar aparcamiento. Entregamos en cualquier punto de Seminyak y te preparamos una moto acorde a la distancia que realmente vas a recorrer.',
      seoTitle: 'Alquiler de scooter Seminyak, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Seminyak con entrega rápida. Entrega gratis desde 3 días, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 3 días o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Seminyak.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>3 días o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Seminyak.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde nuestro almacén en Kerobokan, a pocos minutos de Seminyak.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Las calles de Seminyak son llanas y transitables en algunas zonas, pero Jalan Kayu Aya (Oberoi) y Jalan Laksmana (Petitenget) se congestionan seriamente a última hora de la tarde cuando aumenta el tráfico hacia los beach clubs, con scooters de reparto y coches compitiendo por los mismos carriles estrechos. Un scooter sigue ganando a ese atasco: puedes esquivarlo y aparcar más cerca de las entradas a la playa que cualquier coche.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Seminyak?',
      faqA1: 'Sí — la entrega cubre todo Seminyak. Gratis desde 3 días, Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Seminyak\" más arriba. Para moverte localmente un scooter es suficiente; para trayectos más largos por Bali, una Xmax, V-Strom o Versys es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
      whichBikeExtra: "<p>¿Quieres llegar con estilo, no solo llegar? Las café racer — <strong><a href=\"/es/bikes?group=motorcycle&amp;model=yamaha_xsr\">XSR</a></strong> y <strong><a href=\"/es/bikes?group=motorcycle&amp;model=tvs_ronin225\">Ronin</a></strong> — y los modelos deportivos encajan perfecto en Canggu y Seminyak: ágiles en el tráfico, vistosas en el paseo marítimo y frente a tu café favorito. Si el estilo te importa tanto como la comodidad, esta es tu opción.</p>",
    },
    ubud: {
      name: 'Ubud', prep: 'en',
      h1: 'Alquiler de scooters y motos en Ubud',
      intro: 'Ubud es el corazón cultural y creativo de Bali — arrozales en terrazas, templos y estudios de arte repartidos por un terreno ondulado, realmente montañoso, en lugar de la costa llana del sur. El tráfico en la calle principal, Jalan Raya Ubud, puede ser denso cerca del mercado y del bosque de los monos, pero un scooter igualmente te lleva a las carreteras entre los arrozales y a los callejones tranquilos donde un coche no puede entrar. Entregamos en cualquier punto de Ubud y te preparamos una moto adecuada para las colinas de Ubud, no solo para circular en llano.',
      seoTitle: 'Alquiler de scooter Ubud, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Ubud con entrega rápida al centro, Penestanan, Campuhan y Tegallalang. Entrega gratis desde un mes, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 30 días (1 mes) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Ubud.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>30 días (1 mes) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Ubud.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>La arteria principal de Ubud, Jalan Raya Ubud, se colapsa cerca del mercado y de Monkey Forest Road, especialmente al mediodía y a primera hora de la noche — una de las calles más congestionadas de Bali fuera del sur. Lejos de esa vía, las carreteras entre los arrozales y el Campuhan Ridge son más tranquilas pero realmente montañosas, así que una moto con algo más de potencia (ADV o Xmax) circula con más facilidad que un pequeño scooter urbano.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Ubud?',
      faqA1: 'Sí — la entrega cubre todo Ubud. Gratis desde 30 días (1 mes), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Ubud\" más arriba. Las colinas de Ubud piden algo más de potencia que un scooter urbano de costa llana, sobre todo si vas más allá, hacia los arrozales. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    uluwatu: {
      name: 'Uluwatu', prep: 'en',
      h1: 'Alquiler de scooters y motos en Uluwatu',
      intro: 'Uluwatu se asienta sobre los acantilados calizos del sur de Bali — playas de surf, warungs en el acantilado y la carretera hacia el templo de Uluwatu, repartidos en una zona más extensa que los distritos más llanos del norte. Las carreteras aquí suben y serpentean por el Bukit, y las distancias entre playas son más largas de lo que parecen en un mapa. Entregamos en toda la zona de Uluwatu y te preparamos una moto capaz de con las colinas, no solo con las carreteras de playa.',
      seoTitle: 'Alquiler de scooter Uluwatu, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Uluwatu con entrega rápida a Pecatu, Bingin, Balangan y Padang Padang. Entrega gratis desde 2 semanas, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 14 días (2 semanas) o más · Rp 150.000 fijo en estancias más cortas — en toda la zona de Uluwatu.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>14 días (2 semanas) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en toda la zona de Uluwatu.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Las carreteras de la península del Bukit alrededor de Uluwatu son más montañosas y están más dispersas que en cualquier otro punto de esta lista — ir de una playa a otra (Padang Padang, Bingin, Balangan) a menudo significa una subida de verdad, no un paseo llano. El tráfico en sí es más ligero que en Canggu o Seminyak, pero el terreno hace que una moto con más par se maneje con mucha más comodidad.</p>`,
      faqQ1: '¿Entregáis en toda la zona de Uluwatu?',
      faqA1: 'Sí — la entrega cubre toda la zona de Uluwatu. Gratis desde 14 días (2 semanas), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Uluwatu\" más arriba. Las colinas del Bukit piden algo más de potencia que un scooter urbano de costa llana. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    jimbaran: {
      name: 'Jimbaran', prep: 'en',
      h1: 'Alquiler de scooters y motos en Jimbaran',
      intro: 'Jimbaran es la clásica bahía balinesa de atardecer y marisco — una playa curva bordeada de warungs de pescado a la parrilla, entre el aeropuerto y los acantilados del Bukit. Es más tranquila y espaciosa que el sur, más concurrido, con el parque cultural GWK y las carreteras de acceso al Bukit cerca. Entregamos en cualquier punto de Jimbaran y te preparamos una moto acorde a tu ruta hacia el Bukit o el aeropuerto.',
      seoTitle: 'Alquiler de scooter Jimbaran, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Jimbaran con entrega rápida por toda la bahía y hacia GWK. Entrega gratis desde 2 semanas, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 14 días (2 semanas) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Jimbaran.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>14 días (2 semanas) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Jimbaran.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Jimbaran en sí es bastante tranquila comparada con los focos de surf más concurridos del sur, con la carretera de la bahía y la de acceso a GWK como arterias principales — el tráfico aumenta sobre todo al atardecer, cuando se llenan los warungs de marisco. Un scooter es la forma fácil de recorrer la bahía o subir hacia GWK y el Bukit sin buscar aparcamiento.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Jimbaran?',
      faqA1: 'Sí — la entrega cubre todo Jimbaran. Gratis desde 14 días (2 semanas), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Jimbaran\" más arriba. Para la bahía en sí, un scooter es suficiente; subir hacia el Bukit o GWK es más fácil con más potencia. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    sanur: {
      name: 'Sanur', prep: 'en',
      h1: 'Alquiler de scooters y motos en Sanur',
      intro: 'Sanur es la localidad de playa más tranquila de Bali — un largo paseo marítimo pavimentado, agua poco profunda y un ritmo más pausado que el sur, más concurrido, popular entre familias y entre quienes cogen el barco rápido hacia Nusa Penida y las Gili. Las calles son más llanas y menos congestionadas que los focos de surf del sur, lo que la convierte en un lugar fácil para empezar a conducir. Entregamos en cualquier punto de Sanur y te preparamos una moto acorde a tus planes, ya sea el paseo marítimo o una excursión más lejana.',
      seoTitle: 'Alquiler de scooter Sanur, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Sanur con entrega rápida por el paseo marítimo y la zona del puerto. Entrega gratis desde una semana, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 7 días (1 semana) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Sanur.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>7 días (1 semana) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Sanur.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Sanur es uno de los distritos más tranquilos para conducir — el paseo marítimo es relajado y amigable con los scooters, y las calles hacia el interior en dirección a Denpasar tienen más tráfico que la propia costa, pero nada comparable a la hora punta de Kuta o Seminyak. Un lugar cómodo para acostumbrarte a conducir en Bali antes de ir más lejos.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Sanur?',
      faqA1: 'Sí — la entrega cubre todo Sanur. Gratis desde 7 días (1 semana), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Sanur\" más arriba. Sanur en sí es llano y fácil con un scooter urbano; para excursiones más lejanas, una Xmax, V-Strom o Versys es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    kuta: {
      name: 'Kuta', prep: 'en',
      h1: 'Alquiler de scooters y motos en Kuta',
      intro: 'Kuta es la franja turística original de Bali — Kuta Beach, la vida nocturna y las tiendas de Legian, todo denso y transitable a pie pero a menudo atascado, especialmente cerca de Jalan Legian y del centro comercial Beachwalk. Un scooter sigue siendo la forma más rápida de atravesarlo, y Kuta es el más cercano al aeropuerto Ngurah Rai de estos 9 distritos. Entregamos en cualquier punto de Kuta y te preparamos una moto acorde a tu ruta más allá de la franja.',
      seoTitle: 'Alquiler de scooter Kuta, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Kuta con entrega rápida a Legian, Tuban y Kuta Beach — el distrito más cercano al aeropuerto. Entrega gratis desde una semana, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 7 días (1 semana) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Kuta.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>7 días (1 semana) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Kuta.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Kuta y Legian están entre las calles más congestionadas de Bali — Jalan Legian y las carreteras alrededor del centro comercial Beachwalk se colapsan buena parte de la tarde y la noche, agravado por la densidad de peatones, taxis y scooters de reparto. Un scooter sigue siendo más rápido que un coche, y la cercanía de Kuta al aeropuerto es práctica para llegadas tempranas o salidas tardías.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Kuta?',
      faqA1: 'Sí — la entrega cubre todo Kuta. Gratis desde 7 días (1 semana), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Kuta\" más arriba. Para la franja en sí, un scooter es suficiente; para trayectos más largos por Bali, una Xmax, V-Strom o Versys es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    'nusa-dua': {
      name: 'Nusa Dua', prep: 'en',
      h1: 'Alquiler de scooters y motos en Nusa Dua',
      intro: 'Nusa Dua es el distrito balinés de resorts cerrados — carreteras anchas y tranquilas, jardines cuidados y playas serenas, un contraste deliberado con el bullicio más al norte. Es más extenso de lo que parece desde dentro de un resort, y un scooter es la forma práctica de llegar a la playa, al puerto de barcos o al Bukit más allá del enclave. Entregamos en cualquier punto de Nusa Dua y te preparamos una moto acorde a tus planes, ya sea el paseo marítimo o una excursión más adentro de Bali.',
      seoTitle: 'Alquiler de scooter Nusa Dua, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Nusa Dua con entrega rápida por la zona de resorts ITDC y Benoa. Entrega gratis desde 2 semanas, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 14 días (2 semanas) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Nusa Dua.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>14 días (2 semanas) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Nusa Dua.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Dentro del enclave de resorts ITDC, las carreteras son anchas, tranquilas y están bien mantenidas — realmente la conducción más fácil de esta lista. El tráfico aumenta sobre todo donde la puerta principal de Nusa Dua se une a la carretera hacia Benoa y el resto de Bali, y ese tramo puede colapsarse en horas de desplazamiento al trabajo.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Nusa Dua?',
      faqA1: 'Sí — la entrega cubre todo Nusa Dua. Gratis desde 14 días (2 semanas), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Nusa Dua\" más arriba. Dentro del enclave un scooter es suficiente; para trayectos más largos por Bali, una Xmax, V-Strom o Versys es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    denpasar: {
      name: 'Denpasar', prep: 'en',
      h1: 'Alquiler de scooters y motos en Denpasar',
      intro: 'Denpasar es la capital y la ciudad más grande de Bali — oficinas administrativas, mercados locales y la vida cotidiana real de la isla, menos orientada al turismo que los distritos de playa pero céntrica para quien necesite cruzar Bali rápido. El tráfico en las principales arterias es realmente denso, propio de una ciudad, y un scooter es la forma práctica de moverse rápido. Entregamos en cualquier punto de Denpasar y te preparamos una moto acorde a tu ruta.',
      seoTitle: 'Alquiler de scooter Denpasar, Bali — Entrega gratis y las mejores motos | BikeBaliRent',
      seoDescription: 'Alquiler de scooters y motos en Denpasar con entrega rápida por toda la capital de Bali. Entrega gratis desde una semana, precios transparentes, 60+ motos.',
      deliverySummary: 'Entrega gratis en alquileres de 7 días (1 semana) o más · Rp 150.000 fijo en estancias más cortas — en cualquier punto de Denpasar.',
      deliveryHtml: `<ul>
<li>Entrega gratis en alquileres de <strong>7 días (1 semana) o más</strong>.</li>
<li>Alquileres más cortos: tarifa fija de <strong>Rp 150.000</strong>, en cualquier punto de Denpasar.</li>
<li>La hora de entrega y el punto exacto de encuentro se confirman por WhatsApp tras la reserva.</li>
<li>Entregamos desde un único almacén en Kerobokan.</li>
</ul>
<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>`,
      gettingAroundHtml: `<p>Denpasar tiene el tráfico más denso y urbano de todos los distritos de esta lista — las principales arterias están realmente congestionadas casi todo el horario laboral, más cerca de la hora punta de una capital regional que del atasco de una tarde en un pueblo de playa. Un scooter aquí es menos opcional que en cualquier otro sitio — esquivar el tráfico lento suele ser la única forma realista de moverse rápido.</p>`,
      faqQ1: '¿Entregáis en cualquier punto de Denpasar?',
      faqA1: 'Sí — la entrega cubre todo Denpasar. Gratis desde 7 días (1 semana), Rp 150.000 fijo en estancias más cortas.',
      faqQ4: '¿Basta con un scooter, o debería alquilar algo más grande?',
      faqA4: "Depende de tus planes — mira \"Qué moto elegir en Denpasar\" más arriba. Para moverte por la ciudad un scooter es suficiente; para trayectos más largos por Bali, una Xmax, V-Strom o Versys es más cómoda. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:",
    },
    airport: {
        "name": "aeropuerto",
        "prep": "en el",
        "h1": "Alquiler de scooters y motos con entrega en el aeropuerto",
        "intro": "¿Acabas de aterrizar en Bali y quieres salir directo en moto? Te recibimos a un par de minutos de la salida de llegadas y te entregamos la moto antes de que consigas un taxi. La entrega en el aeropuerto está disponible casi a cualquier hora, y te preparamos una moto acorde a tus planes en Bali.",
        "seoTitle": "Alquiler de scooter en el aeropuerto de Bali (DPS) — Te recibimos al llegar | BikeBaliRent",
        "seoDescription": "Alquiler de scooters y motos con entrega en el aeropuerto Ngurah Rai (DPS), Bali. Te recibimos a 1–3 minutos de la salida de llegadas, precios transparentes, 60+ motos.",
        "deliverySummary": "Entrega gratis en alquileres de 7+ días (1 semana) · Rp 150.000 fijo para alquileres más cortos — hasta la terminal del aeropuerto.",
        "deliveryHtml": "<ul>\n<li>Entrega gratis en alquileres de <strong>7 días o más (1 semana)</strong>.</li>\n<li>Alquileres más cortos: tarifa fija de entrega de <strong>Rp 150.000</strong>.</li>\n<li>La hora exacta y el punto de encuentro se confirman por WhatsApp tras la reserva.</li>\n</ul>\n<p>Podemos entregar casi a cualquier hora — las entregas por la tarde-noche o de madrugada fuera del horario habitual tienen un coste adicional y deben acordarse con antelación.</p>\n<p>Ten en cuenta que salir de la terminal lleva su tiempo — esperar al cliente entre 1,5 y 3 horas no es raro.</p>\n<p>No esperamos justo en la salida — hay mucho movimiento y una espera larga ahí puede costarnos una multa. Te recibimos a 1–3 minutos a pie de la salida, en la zona de aparcamiento de motos.</p>",
        "gettingAroundHtml": null,
        "faqQ1": "¿Reciben a los pasajeros en el aeropuerto Ngurah Rai?",
        "faqA1": "Sí — te recibimos a 1–3 minutos a pie de la salida de llegadas, en la zona de aparcamiento de motos. Ten en cuenta un margen después de aterrizar — esperar al cliente entre 1,5 y 3 horas no es raro.",
        "faqIdpQOverride": "¿Necesito un permiso de conducir internacional para circular por Bali con una moto alquilada?",
        "faqQ4": "¿Qué moto elegir si acabo de aterrizar?",
        "faqA4": "Depende de tus planes en Bali — mira \"Qué moto elegir\" más arriba: un scooter para la ciudad, una ADV o Xmax para trayectos más largos, una moto de touring si van dos con equipaje. ¿Quieres algo más grande? Con gusto te sugerimos otras opciones:"
  },
  },
};
