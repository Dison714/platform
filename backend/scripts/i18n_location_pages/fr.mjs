// Перевод 9 районных страниц — fr. Топонимы остаются на латинице.
export default {
  whichBikeHtml: `<ul>
<li><strong>Trajets en ville</strong> (cafés, boutiques, courts trajets locaux) : une <strong><a href="/fr/bikes?category=honda_pcx160">Honda PCX 160</a></strong> ou <strong><a href="/fr/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — automatique, facile à garer, largement suffisante pour des routes locales plates.</li>
<li><strong>Collines / aventure légère</strong> : une <strong><a href="/fr/bikes?category=honda_adv160">Honda ADV 160</a></strong> — garde au sol plus élevée, toujours automatique, plus rassurante en côte qu'un scooter urbain.</li>
<li><strong>Longues excursions</strong> à travers Bali : une <strong><a href="/fr/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — moteur plus puissant, plus stable à vitesse routière, plus confortable sur de longues distances.</li>
<li><strong>Passager + bagages</strong> / tourisme sur plusieurs jours : une <strong><a href="/fr/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> ou <strong><a href="/fr/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — routières tout-terrain à boîte manuelle, conçues pour rouler à deux avec du chargement, plutôt pour les motards expérimentés.</li>
</ul>`,
  deliveryDisclaimer: 'Les prix ci-dessus sont indicatifs — merci de confirmer le coût exact de la livraison pour vos dates et horaires avec notre équipe.',
  faqBiggerBikeLinkLabel: "Motos",
  faqMinRental: { q: 'Y a-t-il une durée de location minimale ?', a: "Il n'y a pas de minimum — seuls les frais de livraison changent selon la durée de location." },
  faqIdpQ: (district, prep) => `Ai-je besoin d'un permis de conduire international pour rouler ${prep} ${district} ?`,
  faqIdpA: 'Oui, en complément de votre permis national — consultez notre guide complet :',
  faqIdpLinkLabel: 'Rouler à Bali sans permis : les vrais risques',
  faqDepositQ: 'Quelle est votre politique de caution et de dommages ?',
  faqDepositA: 'Consultez notre guide sur la caution et la sécurité :',
  faqDepositLinkLabel: 'Articles caution & sécurité',
  ctaBody: (district, prep) => `Prêt à réserver ? Envoyez-nous vos dates et votre point de retrait ${prep} ${district} sur WhatsApp, et nous confirmerons votre bike et l'heure de livraison.`,
  districts: {
    canggu: {
      name: 'Canggu', prep: 'à',
      h1: 'Location de scooters et motos à Canggu',
      intro: "Canggu est notre zone de livraison la plus active — spots de surf, espaces de coworking et beach clubs concentrés sur quelques kilomètres carrés, avec presque chaque villa ou guesthouse accessible en scooter en quelques minutes. Nous livrons partout à Canggu — Berawa, Batu Bolong, Echo Beach, Pererenan, Tibubeneng — et vous équipons d'un bike adapté à la distance que vous comptez réellement parcourir.",
      seoTitle: 'Location scooter Canggu, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Canggu avec livraison rapide à Berawa, Batu Bolong, Pererenan et Echo Beach. Livraison gratuite pour les locations hebdomadaires, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 15 jours ou plus · Rp 100 000 pour 7–14 jours · Rp 150 000 forfaitaire en dessous d\'une semaine — partout à Canggu.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>15 jours ou plus</strong>.</li>
<li><strong>7–14 jours :</strong> frais de livraison forfaitaires de Rp 100 000, partout à Canggu.</li>
<li>Locations plus courtes (moins de 7 jours) : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Canggu.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis notre dépôt à Kerobokan, à quelques minutes de Canggu.</li>
</ul>
<p>La zone de livraison à Canggu est la même pour tout le secteur, y compris Pererenan et Echo Beach au nord — il n'y a pas de restriction particulière.</p>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Les routes de Canggu ont été construites pour un village de pêcheurs, pas pour le nombre actuel de scooters, voitures et camionnettes de livraison. Attendez-vous à de vrais embouteillages <strong>entre 8h–10h et 16h–19h</strong>, en particulier sur Jalan Raya Canggu, autour de Kerobokan, et sur le Canggu Shortcut reliant Berawa à Batu Bolong — un passage étroit qui peut se bloquer sérieusement aux heures de pointe.</p>
<p>Un scooter reste le moyen le plus rapide de se déplacer : vous pouvez vous faufiler dans le trafic ralenti et vous garer là où une voiture ne peut tout simplement pas accéder. Le stationnement devient difficile juste avant le coucher du soleil près des principaux beach clubs (Batu Bolong / Old Man's, Berawa / Finns) — arrivez un peu en avance si vous y allez pour le coucher du soleil.</p>`,
      faqQ1: 'Livrez-vous partout à Canggu, y compris Pererenan et Echo Beach ?',
      faqA1: 'Oui — la livraison couvre tout Canggu. Gratuite à partir de 15 jours, Rp 100 000 pour 7–14 jours, Rp 150 000 forfaitaire en dessous d\'une semaine.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Canggu » ci-dessus. Si vous restez surtout à Canggu, un scooter suffit largement ; pour des excursions à Ubud/Uluwatu, une NMAX ou une ADV est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
      whichBikeExtra: "<p>Envie d'arriver avec style, pas seulement d'arriver&nbsp;? Les café-racers — <strong><a href=\"/fr/bikes?group=motorcycle&amp;model=yamaha_xsr\">XSR</a></strong> et <strong><a href=\"/fr/bikes?group=motorcycle&amp;model=tvs_ronin225\">Ronin</a></strong> — et les modèles sportifs sont parfaits pour Canggu et Seminyak&nbsp;: maniables dans la circulation, du plus bel effet sur le front de mer et devant votre café préféré. Si le style compte autant que le confort, c'est votre option.</p>",
    },
    seminyak: {
      name: 'Seminyak', prep: 'à',
      h1: 'Location de scooters et motos à Seminyak',
      intro: "Seminyak est le quartier chic des beach clubs et boutiques de Bali — un quadrillage dense de boutiques de créateurs, spas et restaurants entre l'Oberoi et la côte. La plupart des villas et hôtels se trouvent à quelques minutes de route plate de la plage, et un scooter est le moyen le plus simple de passer d'un spot de coucher de soleil à l'autre sans chercher de stationnement. Nous livrons partout à Seminyak et vous équipons d'un bike adapté à la distance que vous comptez réellement parcourir.",
      seoTitle: 'Location scooter Seminyak, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Seminyak avec livraison rapide. Livraison gratuite dès 3 jours, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 3 jours ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Seminyak.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>3 jours ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Seminyak.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis notre dépôt à Kerobokan, à quelques minutes de Seminyak.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Les rues de Seminyak sont plates et praticables à pied par endroits, mais Jalan Kayu Aya (Oberoi) et Jalan Laksmana (Petitenget) deviennent sérieusement encombrées en fin d'après-midi quand le trafic vers les beach clubs augmente — scooters de livraison et voitures se disputent les mêmes voies étroites. Un scooter reste plus rapide que d'attendre dans ce trafic : vous pouvez vous faufiler et vous garer plus près des entrées de plage que n'importe quelle voiture.</p>`,
      faqQ1: 'Livrez-vous partout à Seminyak ?',
      faqA1: 'Oui — la livraison couvre tout Seminyak. Gratuite à partir de 3 jours, Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Seminyak » ci-dessus. Pour rouler localement, un scooter suffit ; pour de plus longs trajets à travers Bali, une Xmax, V-Strom ou Versys est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
      whichBikeExtra: "<p>Envie d'arriver avec style, pas seulement d'arriver&nbsp;? Les café-racers — <strong><a href=\"/fr/bikes?group=motorcycle&amp;model=yamaha_xsr\">XSR</a></strong> et <strong><a href=\"/fr/bikes?group=motorcycle&amp;model=tvs_ronin225\">Ronin</a></strong> — et les modèles sportifs sont parfaits pour Canggu et Seminyak&nbsp;: maniables dans la circulation, du plus bel effet sur le front de mer et devant votre café préféré. Si le style compte autant que le confort, c'est votre option.</p>",
    },
    ubud: {
      name: 'Ubud', prep: 'à',
      h1: 'Location de scooters et motos à Ubud',
      intro: "Ubud est le cœur culturel et créatif de Bali — rizières en terrasses, temples et ateliers d'artistes répartis sur un relief vallonné, vraiment collinaire, plutôt que sur la côte plate du sud. La circulation sur l'artère principale, Jalan Raya Ubud, peut être dense près du marché et de la forêt des singes, mais un scooter vous emmène quand même sur les routes entre les rizières et dans les ruelles tranquilles qu'une voiture ne peut pas atteindre. Nous livrons partout à Ubud et vous équipons d'un bike adapté aux collines d'Ubud, pas seulement à une conduite plate.",
      seoTitle: 'Location scooter Ubud, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Ubud avec livraison rapide au centre, à Penestanan, Campuhan et Tegallalang. Livraison gratuite dès un mois, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 30 jours (1 mois) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Ubud.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>30 jours (1 mois) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Ubud.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>L'artère principale d'Ubud, Jalan Raya Ubud, se bouchonne près du marché et de Monkey Forest Road, surtout en milieu de journée et en début de soirée — l'une des rues les plus encombrées de Bali en dehors du sud. À l'écart de cet axe, les routes à travers les rizières et le Campuhan Ridge sont plus calmes mais vraiment vallonnées, un bike un peu plus puissant (ADV ou Xmax) s'y conduit donc plus facilement qu'un petit scooter urbain.</p>`,
      faqQ1: 'Livrez-vous partout à Ubud ?',
      faqA1: 'Oui — la livraison couvre tout Ubud. Gratuite à partir de 30 jours (1 mois), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Ubud » ci-dessus. Les collines d'Ubud demandent un peu plus de puissance qu'un scooter urbain de bord de mer, surtout si vous poussez jusqu'aux rizières. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    uluwatu: {
      name: 'Uluwatu', prep: 'autour d\'',
      h1: 'Location de scooters et motos à Uluwatu',
      intro: "Uluwatu se trouve sur les falaises calcaires du sud de Bali — spots de surf, warungs en haut des falaises et la route vers le temple d'Uluwatu, répartis sur une zone plus étendue que les quartiers plus plats du nord. Les routes ici montent et serpentent sur le Bukit, et les distances entre les plages sont plus longues qu'elles n'y paraissent sur une carte. Nous livrons partout autour d'Uluwatu et vous équipons d'un bike capable de gérer les collines, pas seulement les routes de plage.",
      seoTitle: 'Location scooter Uluwatu, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Uluwatu avec livraison rapide à Pecatu, Bingin, Balangan et Padang Padang. Livraison gratuite dès 2 semaines, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 14 jours (2 semaines) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout autour d\'Uluwatu.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>14 jours (2 semaines) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout autour d'Uluwatu.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Les routes sur la péninsule du Bukit autour d'Uluwatu sont plus vallonnées et plus étendues que partout ailleurs sur cette liste — passer d'une plage à l'autre (Padang Padang, Bingin, Balangan) signifie souvent une vraie montée, pas une balade plate. Le trafic lui-même est plus léger qu'à Canggu ou Seminyak, mais le relief fait qu'un scooter avec plus de couple s'en sort nettement plus confortablement.</p>`,
      faqQ1: 'Livrez-vous partout autour d\'Uluwatu ?',
      faqA1: 'Oui — la livraison couvre toute la zone d\'Uluwatu. Gratuite à partir de 14 jours (2 semaines), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Uluwatu » ci-dessus. Les collines du Bukit demandent un peu plus de puissance qu'un scooter urbain de bord de mer. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    jimbaran: {
      name: 'Jimbaran', prep: 'à',
      h1: 'Location de scooters et motos à Jimbaran',
      intro: "Jimbaran est la baie classique de Bali pour le coucher de soleil et les fruits de mer — une plage incurvée bordée de warungs de poisson grillé, entre l'aéroport et les falaises du Bukit. C'est plus calme et plus étalé que le sud animé, avec le parc culturel GWK et les routes d'accès au Bukit à proximité. Nous livrons partout à Jimbaran et vous équipons d'un bike adapté à votre trajet, vers le Bukit ou vers l'aéroport.",
      seoTitle: 'Location scooter Jimbaran, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Jimbaran avec livraison rapide dans toute la baie et vers GWK. Livraison gratuite dès 2 semaines, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 14 jours (2 semaines) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Jimbaran.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>14 jours (2 semaines) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Jimbaran.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Jimbaran elle-même est assez tranquille comparée aux spots de surf plus animés du sud, avec la route de la baie et la route d'accès à GWK comme axes principaux — le trafic augmente surtout au coucher du soleil, quand les warungs de fruits de mer se remplissent. Un scooter est le moyen facile de longer la baie ou de monter vers GWK et le Bukit sans chercher de stationnement.</p>`,
      faqQ1: 'Livrez-vous partout à Jimbaran ?',
      faqA1: 'Oui — la livraison couvre tout Jimbaran. Gratuite à partir de 14 jours (2 semaines), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Jimbaran » ci-dessus. Pour la baie elle-même, un scooter suffit ; monter vers le Bukit ou GWK est plus facile avec plus de puissance. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    sanur: {
      name: 'Sanur', prep: 'à',
      h1: 'Location de scooters et motos à Sanur',
      intro: "Sanur est la ville balnéaire la plus calme de Bali — une longue promenade pavée en bord de mer, une eau peu profonde et un rythme plus lent que le sud animé, appréciée des familles et de ceux qui prennent le bateau rapide vers Nusa Penida et les Gili. Les rues sont plus plates et moins encombrées que les spots de surf du sud, ce qui en fait un endroit facile pour commencer à rouler. Nous livrons partout à Sanur et vous équipons d'un bike adapté à vos plans, que ce soit la promenade ou une excursion plus lointaine.",
      seoTitle: 'Location scooter Sanur, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Sanur avec livraison rapide le long du front de mer et près du port. Livraison gratuite dès une semaine, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 7 jours (1 semaine) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Sanur.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>7 jours (1 semaine) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Sanur.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Sanur est l'un des quartiers les plus tranquilles pour rouler — la promenade en bord de mer est détendue et adaptée aux scooters, et les rues vers l'intérieur en direction de Denpasar portent plus de trafic que la côte elle-même, mais rien de comparable à l'heure de pointe de Kuta ou Seminyak. Un endroit confortable pour s'habituer à rouler à Bali avant d'aller plus loin.</p>`,
      faqQ1: 'Livrez-vous partout à Sanur ?',
      faqA1: 'Oui — la livraison couvre tout Sanur. Gratuite à partir de 7 jours (1 semaine), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Sanur » ci-dessus. Sanur elle-même est plate et facile avec un scooter urbain ; pour des excursions plus lointaines, une Xmax, V-Strom ou Versys est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    kuta: {
      name: 'Kuta', prep: 'à',
      h1: 'Location de scooters et motos à Kuta',
      intro: "Kuta est la bande touristique originelle de Bali — Kuta Beach, la vie nocturne et les boutiques de Legian, tout est dense et praticable à pied mais souvent bloqué par les embouteillages, en particulier près de Jalan Legian et du centre commercial Beachwalk. Un scooter reste le moyen le plus rapide de s'y faufiler, et Kuta est le plus proche de l'aéroport Ngurah Rai parmi ces 9 quartiers. Nous livrons partout à Kuta et vous équipons d'un bike adapté à votre trajet au-delà de la bande touristique.",
      seoTitle: 'Location scooter Kuta, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: "Location de scooters et motos à Kuta avec livraison rapide à Legian, Tuban et Kuta Beach — quartier le plus proche de l'aéroport. Livraison gratuite dès une semaine, tarifs transparents, 60+ bikes.",
      deliverySummary: 'Livraison gratuite pour toute location de 7 jours (1 semaine) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Kuta.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>7 jours (1 semaine) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Kuta.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Kuta et Legian comptent parmi les rues les plus encombrées de Bali — Jalan Legian et les routes autour du centre commercial Beachwalk sont bloquées une grande partie de l'après-midi et de la soirée, aggravé par la densité de piétons, taxis et scooters de livraison. Un scooter reste plus rapide qu'une voiture, et la proximité de Kuta avec l'aéroport est pratique pour les arrivées tôt le matin ou les départs tardifs.</p>`,
      faqQ1: 'Livrez-vous partout à Kuta ?',
      faqA1: 'Oui — la livraison couvre tout Kuta. Gratuite à partir de 7 jours (1 semaine), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Kuta » ci-dessus. Pour la bande touristique elle-même, un scooter suffit ; pour de plus longs trajets à travers Bali, une Xmax, V-Strom ou Versys est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    'nusa-dua': {
      name: 'Nusa Dua', prep: 'à',
      h1: 'Location de scooters et motos à Nusa Dua',
      intro: "Nusa Dua est le quartier de resorts fermé de Bali — routes larges et calmes, jardins soignés et plages tranquilles, un contraste volontaire avec l'agitation plus au nord. C'est plus étendu qu'il n'y paraît depuis l'intérieur d'un resort, et un scooter est le moyen pratique d'atteindre la plage, le port de bateaux ou le Bukit au-delà de l'enclave. Nous livrons partout à Nusa Dua et vous équipons d'un bike adapté à vos plans, que ce soit la promenade ou une excursion plus loin dans Bali.",
      seoTitle: 'Location scooter Nusa Dua, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Nusa Dua avec livraison rapide dans la zone de resorts ITDC et à Benoa. Livraison gratuite dès 2 semaines, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 14 jours (2 semaines) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Nusa Dua.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>14 jours (2 semaines) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Nusa Dua.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>À l'intérieur de l'enclave de resorts ITDC, les routes sont larges, calmes et bien entretenues — vraiment la conduite la plus facile de cette liste. Le trafic augmente surtout là où l'entrée principale de Nusa Dua rejoint la route vers Benoa et le reste de Bali, et ce tronçon peut se bloquer aux heures de pointe.</p>`,
      faqQ1: 'Livrez-vous partout à Nusa Dua ?',
      faqA1: 'Oui — la livraison couvre tout Nusa Dua. Gratuite à partir de 14 jours (2 semaines), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Nusa Dua » ci-dessus. À l'intérieur de l'enclave, un scooter suffit ; pour de plus longs trajets à travers Bali, une Xmax, V-Strom ou Versys est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    denpasar: {
      name: 'Denpasar', prep: 'à',
      h1: 'Location de scooters et motos à Denpasar',
      intro: "Denpasar est la capitale et la plus grande ville de Bali — administrations, marchés locaux et la vraie vie quotidienne de l'île, moins tournée vers le tourisme que les quartiers balnéaires mais centrale pour quiconque doit traverser Bali rapidement. La circulation sur les grands axes est vraiment dense, digne d'une ville, et un scooter est le moyen pratique de se déplacer vite. Nous livrons partout à Denpasar et vous équipons d'un bike adapté à votre trajet.",
      seoTitle: 'Location scooter Denpasar, Bali — Livraison gratuite & meilleurs bikes | BikeBaliRent',
      seoDescription: 'Location de scooters et motos à Denpasar avec livraison rapide dans toute la capitale de Bali. Livraison gratuite dès une semaine, tarifs transparents, 60+ bikes.',
      deliverySummary: 'Livraison gratuite pour toute location de 7 jours (1 semaine) ou plus · Rp 150 000 forfaitaire pour les séjours plus courts — partout à Denpasar.',
      deliveryHtml: `<ul>
<li>Livraison gratuite pour toute location de <strong>7 jours (1 semaine) ou plus</strong>.</li>
<li>Locations plus courtes : frais forfaitaires de <strong>Rp 150 000</strong>, partout à Denpasar.</li>
<li>L'heure de livraison et le point de rendez-vous exact sont confirmés par WhatsApp après la réservation.</li>
<li>Nous livrons depuis un dépôt unique à Kerobokan.</li>
</ul>
<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>`,
      gettingAroundHtml: `<p>Denpasar a le trafic le plus dense et le plus urbain de tous les quartiers de cette liste — les grands axes sont vraiment encombrés presque toute la journée de travail, plus proche de l'heure de pointe d'une capitale régionale que de l'embouteillage de fin d'après-midi d'une ville balnéaire. Un scooter y est moins optionnel que partout ailleurs — se faufiler dans le trafic ralenti est souvent le seul moyen réaliste d'avancer vite.</p>`,
      faqQ1: 'Livrez-vous partout à Denpasar ?',
      faqA1: 'Oui — la livraison couvre tout Denpasar. Gratuite à partir de 7 jours (1 semaine), Rp 150 000 forfaitaire pour les séjours plus courts.',
      faqQ4: 'Un scooter suffit-il, ou dois-je louer quelque chose de plus grand ?',
      faqA4: "Cela dépend de vos plans — voir « Quel bike choisir à Denpasar » ci-dessus. Pour rouler en ville, un scooter suffit ; pour de plus longs trajets à travers Bali, une Xmax, V-Strom ou Versys est plus confortable. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
    },
    airport: {
        "name": "aéroport",
        "prep": "à l'",
        "h1": "Location de scooters et motos avec livraison à l'aéroport",
        "intro": "Vous venez d'atterrir à Bali et voulez partir directement en scooter ? On vous accueille à quelques minutes de la sortie arrivées et on vous remet votre bike avant même que vous ayez trouvé un taxi. La livraison à l'aéroport est possible presque à toute heure, et on vous équipe d'un bike adapté à la suite de votre séjour à Bali.",
        "seoTitle": "Location de scooter à l'aéroport de Bali (DPS) — On vous accueille à l'arrivée | BikeBaliRent",
        "seoDescription": "Location de scooters et motos avec livraison à l'aéroport Ngurah Rai (DPS), Bali. Accueil à 1–3 minutes de la sortie arrivées, tarifs transparents, 60+ bikes.",
        "deliverySummary": "Livraison gratuite pour les locations de 7 jours ou plus (1 semaine) · Rp 150 000 fixe pour les locations plus courtes — jusqu'au terminal de l'aéroport.",
        "deliveryHtml": "<ul>\n<li>Livraison gratuite pour les locations de <strong>7 jours ou plus (1 semaine)</strong>.</li>\n<li>Locations plus courtes : frais de livraison fixes de <strong>Rp 150 000</strong>.</li>\n<li>Heure exacte et point de rendez-vous confirmés par WhatsApp après la réservation.</li>\n</ul>\n<p>Nous pouvons livrer presque à toute heure — les livraisons en soirée ou de nuit en dehors des horaires habituels sont payantes et doivent être convenues à l'avance.</p>\n<p>Merci d'estimer de façon réaliste le temps nécessaire pour sortir du terminal, en tenant compte de la récupération des bagages, du contrôle des passeports et de la douane. Ainsi notre chauffeur n'aura pas à vous attendre trop longtemps.</p>\n<p>Nous n'attendons pas directement à la sortie — c'est très fréquenté, et une longue attente là-bas peut nous valoir une amende. On vous accueille à 1–3 minutes à pied de la sortie, au parking des bikes.</p>\n<p><a class=\"btn-cta loc-cta-btn loc-cta-outline\" href=\"https://maps.app.goo.gl/3cmkLZEnQ1zisxPA8?g_st=atm\" target=\"_blank\" rel=\"noopener noreferrer\">Point de rendez-vous à l'aéroport</a></p>\n<div class=\"loc-see-all-row\"><p class=\"loc-see-all-note\" style=\"margin:0\">Nous pouvons livrer n'importe quel bike de notre flotte à l'aéroport.</p><a class=\"btn-cta loc-cta-btn\" href=\"/fr/bikes\">Parcourir tous les bikes</a></div>",
        "gettingAroundHtml": null,
        "faqQ1": "Accueillez-vous les arrivants à l'aéroport Ngurah Rai ?",
        "faqA1": "Oui — on vous accueille à 1–3 minutes à pied de la sortie arrivées, au parking des bikes. Merci d'estimer de façon réaliste le temps nécessaire pour sortir du terminal, en tenant compte de la récupération des bagages, du contrôle des passeports et de la douane. Ainsi notre chauffeur n'aura pas à vous attendre trop longtemps.",
        "faqIdpQOverride": "Ai-je besoin d'un permis de conduire international pour rouler à Bali avec un bike loué ?",
        "faqQ4": "Quel bike choisir si je viens d'atterrir ?",
        "faqA4": "Cela dépend de la suite de votre séjour à Bali : un scooter pour la ville, une ADV ou Xmax pour les trajets plus longs, un bike de tourisme si vous êtes deux avec des bagages. Vous voulez quelque chose de plus gros ? Nous vous proposerons volontiers d'autres options :",
        "whichBikeHtmlOverride": null
  },
  },
};
