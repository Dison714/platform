// Перевод 9 районных страниц — it. Топонимы остаются на латинице.
export default {
  whichBikeHtml: `<ul>
<li><strong>Guida in città</strong> (caffè, negozi, brevi spostamenti locali): una <strong>Honda PCX 160</strong> o <strong>Yamaha Nmax 155</strong> — completamente automatica, facile da parcheggiare, più che sufficiente per strade locali pianeggianti.</li>
<li><strong>Colline / avventura leggera</strong>: una <strong>Honda ADV 160</strong> — maggiore altezza da terra, sempre automatica, più sicura in salita rispetto a uno scooter urbano.</li>
<li><strong>Lunghe gite</strong> in giro per Bali: una <strong>Yamaha Xmax 250</strong> — motore più potente, più stabile a velocità autostradale, più comoda su lunghe distanze.</li>
<li><strong>Passeggero + bagagli</strong> / turismo su più giorni: una <strong>Suzuki V-Strom 250</strong> o <strong>Kawasaki Versys</strong> — moto da turismo con cambio manuale, pensate per viaggiare in due con carico, più adatte a motociclisti con più esperienza.</li>
</ul>`,
  deliveryDisclaimer: 'I prezzi sopra indicati sono indicativi — conferma il costo esatto della consegna per le tue date e i tuoi orari con il nostro team.',
  faqMinRental: { q: "C'è una durata minima di noleggio?", a: 'Non c\'è un minimo — solo il costo di consegna cambia in base alla durata del noleggio.' },
  faqIdpQ: (district, prep) => `Mi serve una patente internazionale per guidare ${prep} ${district}?`,
  faqIdpA: 'Sì, insieme alla tua patente nazionale — consulta la nostra guida completa:',
  faqIdpLinkLabel: 'Guidare a Bali senza patente: i rischi reali',
  faqDepositQ: 'Qual è la vostra politica su cauzione e danni?',
  faqDepositA: 'Consulta la nostra guida su cauzione e sicurezza:',
  faqDepositLinkLabel: 'Articoli su cauzione e sicurezza',
  ctaBody: (district, prep) => `Pronto a prenotare? Scrivici su WhatsApp le tue date e il punto di ritiro ${prep} ${district}, e confermeremo la moto e l'orario di consegna.`,
  districts: {
    canggu: {
      name: 'Canggu', prep: 'a',
      h1: 'Noleggio scooter e moto a Canggu',
      intro: 'Canggu è la nostra zona di consegna più intensa — spot da surf, spazi di coworking e beach club concentrati in pochi chilometri quadrati, con quasi ogni villa o guesthouse raggiungibile in scooter in pochi minuti. Consegniamo ovunque a Canggu — Berawa, Batu Bolong, Echo Beach, Pererenan, Tibubeneng — e ti prepariamo una moto adatta alla distanza che percorrerai davvero.',
      seoTitle: 'Noleggio scooter Canggu, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Canggu con consegna rapida a Berawa, Batu Bolong, Pererenan ed Echo Beach. Consegna gratuita per noleggi settimanali, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 15 giorni o più · Rp 100.000 per 7–14 giorni · Rp 150.000 fisso sotto una settimana — ovunque a Canggu.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>15 giorni o più</strong>.</li>
<li><strong>7–14 giorni:</strong> costo fisso di consegna di Rp 100.000, ovunque a Canggu.</li>
<li>Noleggi più brevi (sotto i 7 giorni): costo fisso di <strong>Rp 150.000</strong>, ovunque a Canggu.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo dal nostro deposito a Kerobokan, a pochi minuti da Canggu.</li>
</ul>
<p>La zona di consegna a Canggu è la stessa per tutta l'area, compresi Pererenan ed Echo Beach a nord — non ci sono restrizioni particolari.</p>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Le strade di Canggu sono state costruite per un villaggio di pescatori, non per l'attuale numero di scooter, auto e furgoni per le consegne. Aspettati traffico vero e proprio <strong>tra le 8–10 del mattino e le 16–19</strong>, soprattutto su Jalan Raya Canggu, intorno a Kerobokan e sul Canggu Shortcut che collega Berawa a Batu Bolong — un tratto stretto che può bloccarsi seriamente nelle ore di punta.</p>
<p>Uno scooter resta comunque il modo più veloce per spostarsi: puoi infilarti nel traffico lento e parcheggiare dove un'auto semplicemente non entra. Il parcheggio si complica proprio al tramonto vicino ai principali beach club (Batu Bolong / Old Man's, Berawa / Finns) — arriva un po' prima se ci vai per il tramonto.</p>`,
      faqQ1: 'Consegnate ovunque a Canggu, incluse Pererenan ed Echo Beach?',
      faqA1: 'Sì — la consegna copre tutta Canggu. Gratuita da 15 giorni, Rp 100.000 per 7–14 giorni, Rp 150.000 fisso sotto una settimana.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Canggu" più sopra. Se resti soprattutto a Canggu, uno scooter è più che sufficiente; per gite a Ubud/Uluwatu, una NMAX o ADV è più comoda.',
    },
    seminyak: {
      name: 'Seminyak', prep: 'a',
      h1: 'Noleggio scooter e moto a Seminyak',
      intro: "Seminyak è la fascia esclusiva di beach club e boutique di Bali — una fitta griglia di negozi di design, spa e ristoranti tra l'Oberoi e la costa. La maggior parte delle ville e degli hotel si trova a pochi minuti pianeggianti dalla spiaggia, e uno scooter è il modo più semplice per spostarsi tra i punti panoramici del tramonto senza cercare parcheggio. Consegniamo ovunque a Seminyak e ti prepariamo una moto adatta alla distanza che percorrerai davvero.",
      seoTitle: 'Noleggio scooter Seminyak, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Seminyak con consegna rapida. Consegna gratuita da 3 giorni, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 3 giorni o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Seminyak.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>3 giorni o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Seminyak.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo dal nostro deposito a Kerobokan, a pochi minuti da Seminyak.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Le strade di Seminyak sono pianeggianti e percorribili a piedi in alcuni tratti, ma Jalan Kayu Aya (Oberoi) e Jalan Laksmana (Petitenget) diventano seriamente congestionate nel tardo pomeriggio quando aumenta il traffico verso i beach club, con scooter delle consegne e auto in competizione per le stesse corsie strette. Uno scooter batte comunque quel traffico: puoi infilarti e parcheggiare più vicino agli ingressi della spiaggia di qualsiasi auto.</p>`,
      faqQ1: 'Consegnate ovunque a Seminyak?',
      faqA1: 'Sì — la consegna copre tutta Seminyak. Gratuita da 3 giorni, Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Seminyak" più sopra. Per gli spostamenti locali uno scooter è più che sufficiente; per viaggi più lunghi in giro per Bali, una Xmax, V-Strom o Versys è più comoda.',
    },
    ubud: {
      name: 'Ubud', prep: 'a',
      h1: 'Noleggio scooter e moto a Ubud',
      intro: "Ubud è il cuore culturale e creativo di Bali — risaie a terrazza, templi e atelier d'artista su un terreno collinare, davvero montuoso, invece della costa piatta del sud. Il traffico sulla via principale, Jalan Raya Ubud, può essere intenso vicino al mercato e alla foresta delle scimmie, ma uno scooter ti porta comunque sulle strade tra le risaie e nei vicoli tranquilli dove un'auto non può arrivare. Consegniamo ovunque a Ubud e ti prepariamo una moto adatta alle colline di Ubud, non solo alla guida in piano.",
      seoTitle: 'Noleggio scooter Ubud, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Ubud con consegna rapida al centro, a Penestanan, Campuhan e Tegallalang. Consegna gratuita da un mese, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 30 giorni (1 mese) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Ubud.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>30 giorni (1 mese) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Ubud.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>L'arteria principale di Ubud, Jalan Raya Ubud, si blocca vicino al mercato e a Monkey Forest Road soprattutto a mezzogiorno e in prima serata — una delle strade più congestionate di Bali fuori dal sud. Lontano da quel tratto, le strade tra le risaie e il Campuhan Ridge sono più tranquille ma davvero collinari, quindi una moto un po' più potente (ADV o Xmax) si guida più facilmente rispetto a un piccolo scooter urbano.</p>`,
      faqQ1: 'Consegnate ovunque a Ubud?',
      faqA1: 'Sì — la consegna copre tutta Ubud. Gratuita da 30 giorni (1 mese), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Ubud" più sopra. Le colline di Ubud richiedono un po\' più di potenza rispetto a uno scooter urbano di costa piatta, soprattutto se ti spingi oltre, verso le risaie.',
    },
    uluwatu: {
      name: 'Uluwatu', prep: 'nella zona di',
      h1: 'Noleggio scooter e moto a Uluwatu',
      intro: "Uluwatu si trova sulle scogliere calcaree del sud di Bali — spot da surf, warung sulla scogliera e la strada per il tempio di Uluwatu, distribuiti su un'area più ampia rispetto ai distretti più pianeggianti a nord. Le strade qui salgono e si snodano sul Bukit, e le distanze tra le spiagge sono più lunghe di quanto sembrino sulla mappa. Consegniamo in tutta la zona di Uluwatu e ti prepariamo una moto capace di affrontare le colline, non solo le strade di spiaggia.",
      seoTitle: 'Noleggio scooter Uluwatu, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Uluwatu con consegna rapida a Pecatu, Bingin, Balangan e Padang Padang. Consegna gratuita da 2 settimane, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 14 giorni (2 settimane) o più · Rp 150.000 fisso per soggiorni più brevi — in tutta la zona di Uluwatu.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>14 giorni (2 settimane) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, in tutta la zona di Uluwatu.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Le strade della penisola del Bukit intorno a Uluwatu sono più collinari e disperse rispetto a qualsiasi altro posto in questa lista — andare da una spiaggia all'altra (Padang Padang, Bingin, Balangan) spesso significa una vera salita, non una guida in piano. Il traffico in sé è più leggero rispetto a Canggu o Seminyak, ma il terreno fa sì che una moto con più coppia si guidi in modo decisamente più comodo.</p>`,
      faqQ1: 'Consegnate in tutta la zona di Uluwatu?',
      faqA1: 'Sì — la consegna copre tutta la zona di Uluwatu. Gratuita da 14 giorni (2 settimane), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Uluwatu" più sopra. Le colline del Bukit richiedono un po\' più di potenza rispetto a uno scooter urbano di costa piatta.',
    },
    jimbaran: {
      name: 'Jimbaran', prep: 'a',
      h1: 'Noleggio scooter e moto a Jimbaran',
      intro: "Jimbaran è la classica baia balinese del tramonto e del pesce — una spiaggia curva costeggiata da warung di pesce alla griglia, tra l'aeroporto e le scogliere del Bukit. È più tranquilla e dispersa rispetto al sud più affollato, con il parco culturale GWK e le strade di accesso al Bukit nelle vicinanze. Consegniamo ovunque a Jimbaran e ti prepariamo una moto adatta al tuo percorso verso il Bukit o l'aeroporto.",
      seoTitle: 'Noleggio scooter Jimbaran, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Jimbaran con consegna rapida in tutta la baia e verso GWK. Consegna gratuita da 2 settimane, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 14 giorni (2 settimane) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Jimbaran.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>14 giorni (2 settimane) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Jimbaran.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Jimbaran in sé è piuttosto tranquilla rispetto ai punti surf più affollati del sud, con la strada della baia e quella di accesso a GWK come arterie principali — il traffico aumenta soprattutto al tramonto, quando i warung di pesce si riempiono. Uno scooter è il modo facile per percorrere la baia o salire verso GWK e il Bukit senza cercare parcheggio.</p>`,
      faqQ1: 'Consegnate ovunque a Jimbaran?',
      faqA1: 'Sì — la consegna copre tutta Jimbaran. Gratuita da 14 giorni (2 settimane), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Jimbaran" più sopra. Per la baia in sé uno scooter è sufficiente; salire verso il Bukit o GWK è più facile con più potenza.',
    },
    sanur: {
      name: 'Sanur', prep: 'a',
      h1: 'Noleggio scooter e moto a Sanur',
      intro: "Sanur è la località balneare più tranquilla di Bali — un lungo lungomare pavimentato, acque basse e un ritmo più lento rispetto al sud più affollato, apprezzata da famiglie e da chi prende il traghetto veloce per Nusa Penida e le Gili. Le strade sono più pianeggianti e meno congestionate rispetto ai punti surf del sud, il che la rende un posto facile per iniziare a guidare. Consegniamo ovunque a Sanur e ti prepariamo una moto adatta ai tuoi piani, che sia il lungomare o una gita più lontano.",
      seoTitle: 'Noleggio scooter Sanur, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Sanur con consegna rapida lungo il lungomare e la zona del porto. Consegna gratuita da una settimana, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 7 giorni (1 settimana) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Sanur.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>7 giorni (1 settimana) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Sanur.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Sanur è uno dei distretti più tranquilli in cui guidare — il lungomare è rilassato e adatto agli scooter, e le strade verso l'interno in direzione di Denpasar hanno più traffico della costa stessa, ma niente rispetto all'ora di punta di Kuta o Seminyak. Un posto comodo per abituarsi a guidare a Bali prima di spingersi oltre.</p>`,
      faqQ1: 'Consegnate ovunque a Sanur?',
      faqA1: 'Sì — la consegna copre tutta Sanur. Gratuita da 7 giorni (1 settimana), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Sanur" più sopra. Sanur in sé è piatta e facile con uno scooter urbano; per gite più lontane, una Xmax, V-Strom o Versys è più comoda.',
    },
    kuta: {
      name: 'Kuta', prep: 'a',
      h1: 'Noleggio scooter e moto a Kuta',
      intro: 'Kuta è la fascia turistica originaria di Bali — Kuta Beach, la vita notturna e i negozi di Legian, tutto denso e percorribile a piedi ma spesso bloccato dal traffico, in particolare vicino a Jalan Legian e al centro commerciale Beachwalk. Uno scooter resta il modo più veloce per attraversarla, e Kuta è il distretto più vicino all\'aeroporto Ngurah Rai tra questi 9. Consegniamo ovunque a Kuta e ti prepariamo una moto adatta al tuo percorso oltre la fascia turistica.',
      seoTitle: 'Noleggio scooter Kuta, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: "Noleggio scooter e moto a Kuta con consegna rapida a Legian, Tuban e Kuta Beach — il distretto più vicino all'aeroporto. Consegna gratuita da una settimana, prezzi trasparenti, 60+ moto.",
      deliverySummary: 'Consegna gratuita per noleggi di 7 giorni (1 settimana) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Kuta.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>7 giorni (1 settimana) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Kuta.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Kuta e Legian sono tra le strade più congestionate di Bali — Jalan Legian e le strade intorno al centro commerciale Beachwalk si bloccano per buona parte del pomeriggio e della sera, aggravato dalla densità di pedoni, taxi e scooter delle consegne. Uno scooter resta comunque più veloce di un'auto, e la vicinanza di Kuta all'aeroporto è comoda per arrivi mattutini o partenze serali.</p>`,
      faqQ1: 'Consegnate ovunque a Kuta?',
      faqA1: 'Sì — la consegna copre tutta Kuta. Gratuita da 7 giorni (1 settimana), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Kuta" più sopra. Per la fascia turistica in sé uno scooter è sufficiente; per viaggi più lunghi in giro per Bali, una Xmax, V-Strom o Versys è più comoda.',
    },
    'nusa-dua': {
      name: 'Nusa Dua', prep: 'a',
      h1: 'Noleggio scooter e moto a Nusa Dua',
      intro: "Nusa Dua è il distretto balinese dei resort recintati — strade larghe e tranquille, giardini curati e spiagge calme, un contrasto voluto rispetto alla folla più a nord. È più esteso di quanto sembri dall'interno di un resort, e uno scooter è il modo pratico per raggiungere la spiaggia, il porto delle barche o il Bukit oltre l'enclave. Consegniamo ovunque a Nusa Dua e ti prepariamo una moto adatta ai tuoi piani, che sia la passeggiata sul mare o una gita più addentro a Bali.",
      seoTitle: 'Noleggio scooter Nusa Dua, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: 'Noleggio scooter e moto a Nusa Dua con consegna rapida nella zona resort ITDC e a Benoa. Consegna gratuita da 2 settimane, prezzi trasparenti, 60+ moto.',
      deliverySummary: 'Consegna gratuita per noleggi di 14 giorni (2 settimane) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Nusa Dua.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>14 giorni (2 settimane) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Nusa Dua.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>All'interno dell'enclave resort ITDC, le strade sono larghe, tranquille e ben tenute — davvero la guida più facile di questa lista. Il traffico aumenta soprattutto dove il cancello principale di Nusa Dua incontra la strada verso Benoa e il resto di Bali, e quel tratto può bloccarsi negli orari di pendolarismo.</p>`,
      faqQ1: 'Consegnate ovunque a Nusa Dua?',
      faqA1: 'Sì — la consegna copre tutta Nusa Dua. Gratuita da 14 giorni (2 settimane), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: "Dipende dai tuoi piani — vedi \"Qual è la moto giusta per Nusa Dua\" più sopra. All'interno dell'enclave uno scooter è sufficiente; per viaggi più lunghi in giro per Bali, una Xmax, V-Strom o Versys è più comoda.",
    },
    denpasar: {
      name: 'Denpasar', prep: 'a',
      h1: 'Noleggio scooter e moto a Denpasar',
      intro: "Denpasar è la capitale e la città più grande di Bali — uffici governativi, mercati locali e la vera vita quotidiana dell'isola, meno orientata al turismo rispetto ai distretti di spiaggia ma centrale per chi deve attraversare Bali velocemente. Il traffico sulle arterie principali è davvero denso, da vera città, e uno scooter è il modo pratico per muoversi rapidamente. Consegniamo ovunque a Denpasar e ti prepariamo una moto adatta al tuo percorso.",
      seoTitle: 'Noleggio scooter Denpasar, Bali — Consegna gratuita e le migliori moto | BikeBaliRent',
      seoDescription: "Noleggio scooter e moto a Denpasar con consegna rapida in tutta la capitale di Bali. Consegna gratuita da una settimana, prezzi trasparenti, 60+ moto.",
      deliverySummary: 'Consegna gratuita per noleggi di 7 giorni (1 settimana) o più · Rp 150.000 fisso per soggiorni più brevi — ovunque a Denpasar.',
      deliveryHtml: `<ul>
<li>Consegna gratuita per noleggi di <strong>7 giorni (1 settimana) o più</strong>.</li>
<li>Noleggi più brevi: costo fisso di <strong>Rp 150.000</strong>, ovunque a Denpasar.</li>
<li>Orario di consegna e punto d'incontro esatto vengono confermati su WhatsApp dopo la prenotazione.</li>
<li>Consegniamo da un unico deposito a Kerobokan.</li>
</ul>
<p>Possiamo consegnare quasi a qualsiasi ora — le consegne serali o notturne fuori dall'orario abituale sono a pagamento e vanno concordate in anticipo.</p>`,
      gettingAroundHtml: `<p>Denpasar ha il traffico più denso e cittadino di tutti i distretti in questa lista — le arterie principali sono davvero congestionate per quasi tutta la giornata lavorativa, più vicino all'ora di punta di una capitale regionale che all'ingorgo pomeridiano di una località balneare. Qui uno scooter è meno opzionale che altrove — infilarsi nel traffico lento è spesso l'unico modo realistico per muoversi velocemente.</p>`,
      faqQ1: 'Consegnate ovunque a Denpasar?',
      faqA1: 'Sì — la consegna copre tutta Denpasar. Gratuita da 7 giorni (1 settimana), Rp 150.000 fisso per soggiorni più brevi.',
      faqQ4: 'Basta uno scooter, o dovrei noleggiare qualcosa di più grande?',
      faqA4: 'Dipende dai tuoi piani — vedi "Qual è la moto giusta per Denpasar" più sopra. Per la guida in città uno scooter è sufficiente; per viaggi più lunghi in giro per Bali, una Xmax, V-Strom o Versys è più comoda.',
    },
  },
};
