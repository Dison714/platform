// Перевод 9 районных страниц — de. Топонимы остаются на латинице (Canggu,
// Seminyak и т.п.) — обычная практика для индонезийских топонимов без
// устоявшегося немецкого экзонима, transliteration не нужна.
export default {
  whichBikeHtml: `<ul>
<li><strong>Stadtfahrten</strong> (Cafés, Geschäfte, kurze Strecken): eine <strong>Honda PCX 160</strong> oder <strong>Yamaha Nmax 155</strong> — vollautomatisch, leicht zu parken, völlig ausreichend für flache Straßen vor Ort.</li>
<li><strong>Hügel / leichtes Abenteuer</strong>: eine <strong>Honda ADV 160</strong> — mehr Bodenfreiheit, ebenfalls automatisch, sicherer an Steigungen als ein Stadtroller.</li>
<li><strong>Lange Tagesausflüge</strong> quer durch Bali: eine <strong>Yamaha Xmax 250</strong> — stärkerer Motor, stabiler bei Autobahntempo, komfortabler auf langen Strecken.</li>
<li><strong>Beifahrer + Gepäck</strong> / mehrtägige Touren: eine <strong>Suzuki V-Strom 250</strong> oder <strong>Kawasaki Versys</strong> — Reiseenduros mit Schaltung, ausgelegt für zwei Personen mit Gepäck, am besten für erfahrenere Fahrer.</li>
</ul>`,
  deliveryDisclaimer: 'Die oben genannten Preise sind Richtwerte — die genauen Lieferkosten für deine Daten und Zeiten bitte mit unserem Team bestätigen.',
  faqMinRental: { q: 'Gibt es eine Mindestmietdauer?', a: 'Es gibt kein Minimum — nur die Liefergebühr ändert sich mit der Mietdauer.' },
  faqIdpQ: (district, prep) => `Brauche ich einen internationalen Führerschein, um ${prep} ${district} zu fahren?`,
  faqIdpA: 'Ja, zusätzlich zu deinem Heimatführerschein — unseren vollständigen Guide findest du hier:',
  faqIdpLinkLabel: 'Ohne Führerschein auf Bali fahren: die echten Risiken',
  faqDepositQ: 'Wie sieht eure Kaution- und Schadensregelung aus?',
  faqDepositA: 'Sieh dir unseren Guide zu Kaution & Sicherheit an:',
  faqDepositLinkLabel: 'Artikel zu Kaution & Sicherheit',
  ctaBody: (district, prep) => `Bereit zu buchen? Schick uns auf WhatsApp deine Daten und deinen Abholort ${prep} ${district}, und wir bestätigen dein Bike und die Lieferzeit.`,
  districts: {
    canggu: {
      name: 'Canggu', prep: 'in',
      h1: 'Roller- & Motorradverleih in Canggu',
      intro: 'Canggu ist unser meistgenutztes Liefergebiet — Surfspots, Coworking-Spaces und Beachclubs auf wenigen Quadratkilometern, fast jede Villa und jedes Gästehaus ist in Minuten mit dem Roller erreichbar. Wir liefern überallhin in Canggu — Berawa, Batu Bolong, Echo Beach, Pererenan, Tibubeneng — und geben dir ein Bike, das zu deiner tatsächlichen Reichweite passt.',
      seoTitle: 'Rollerverleih Canggu, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Canggu mit schneller Lieferung nach Berawa, Batu Bolong, Pererenan und Echo Beach. Kostenlose Lieferung bei wöchentlicher Miete, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 15 Tagen Miete · Rp 100.000 für 7–14 Tage · Rp 150.000 Pauschale unter einer Woche — überallhin in Canggu.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 15 Tagen</strong>.</li>
<li><strong>7–14 Tage:</strong> Pauschalgebühr von Rp 100.000, überallhin in Canggu.</li>
<li>Kürzere Mieten (unter 7 Tagen): Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Canggu.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus unserem Depot in Kerobokan, nur Minuten von Canggu entfernt.</li>
</ul>
<p>Das Liefergebiet in Canggu ist für die gesamte Gegend gleich, einschließlich Pererenan und Echo Beach im Norden — es gibt keine besonderen Einschränkungen.</p>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Canggus Straßen wurden für ein Fischerdorf gebaut, nicht für die heutige Menge an Rollern, Autos und Lieferwagen. Echter Stau ist zu erwarten <strong>zwischen 8–10 Uhr und 16–19 Uhr</strong>, besonders auf der Jalan Raya Canggu, rund um Kerobokan und auf dem Canggu Shortcut zwischen Berawa und Batu Bolong — eine enge Strecke, die zu Stoßzeiten stark verstopfen kann.</p>
<p>Ein Roller bleibt trotzdem die schnellste Art, sich fortzubewegen: Du kannst dich durch langsamen Verkehr schlängeln und dort parken, wo ein Auto einfach nicht hinkommt. Kurz vor Sonnenuntergang wird es eng bei den großen Beachclubs (Batu Bolong / Old Man's, Berawa / Finns) — komm etwas früher, wenn du zum Sonnenuntergang dorthin willst.</p>`,
      faqQ1: 'Liefert ihr überallhin in Canggu, auch nach Pererenan und Echo Beach?',
      faqA1: 'Ja — die Lieferung deckt ganz Canggu ab. Kostenlos ab 15 Tagen, Rp 100.000 für 7–14 Tage, Rp 150.000 Pauschale unter einer Woche.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Canggu" oben. Wenn du hauptsächlich in Canggu bleibst, reicht ein Roller; für Tagesausflüge nach Ubud/Uluwatu ist eine NMAX oder ADV komfortabler.',
    },
    seminyak: {
      name: 'Seminyak', prep: 'in',
      h1: 'Roller- & Motorradverleih in Seminyak',
      intro: 'Seminyak ist Balis exklusiver Streifen aus Beachclubs und Boutiquen — ein dichtes Raster aus Designerläden, Spas und Restaurants zwischen dem Oberoi und der Küste. Die meisten Villen und Hotels liegen nur eine kurze, flache Fahrt vom Strand entfernt, und ein Roller ist die einfachste Art, zwischen den Sonnenuntergangsspots zu wechseln, ohne nach Parkplätzen zu suchen. Wir liefern überallhin in Seminyak und geben dir ein Bike, das zu deiner tatsächlichen Reichweite passt.',
      seoTitle: 'Rollerverleih Seminyak, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Seminyak mit schneller Lieferung. Kostenlose Lieferung ab 3 Tagen, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 3 Tagen Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Seminyak.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 3 Tagen</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Seminyak.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus unserem Depot in Kerobokan, nur Minuten von Seminyak entfernt.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Seminyaks Straßen sind streckenweise flach und begehbar, aber die Jalan Kayu Aya (Oberoi) und die Jalan Laksmana (Petitenget) sind am späten Nachmittag stark verstopft, wenn der Beachclub-Verkehr zunimmt — Lieferroller und Autos kämpfen um dieselben engen Fahrspuren. Ein Roller schlägt diesen Stau trotzdem: Du kannst dich durchschlängeln und näher an den Stranteingängen parken als jedes Auto.</p>`,
      faqQ1: 'Liefert ihr überallhin in Seminyak?',
      faqA1: 'Ja — die Lieferung deckt ganz Seminyak ab. Kostenlos ab 3 Tagen, Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Seminyak" oben. Für Fahrten vor Ort reicht ein Roller; für längere Touren quer durch Bali ist eine Xmax, V-Strom oder Versys komfortabler.',
    },
    ubud: {
      name: 'Ubud', prep: 'in',
      h1: 'Roller- & Motorradverleih in Ubud',
      intro: 'Ubud ist Balis kulturelles und kreatives Herz — Reisterrassen, Tempel und Kunstateliers auf hügeligem, wirklich bergigem Gelände statt der flachen Küste im Süden. Auf der Hauptstraße Jalan Raya Ubud kann es rund um den Markt und den Monkey Forest dicht werden, aber ein Roller bringt dich trotzdem zu den Straßen zwischen den Reisterrassen und in die ruhigen Seitengassen, die ein Auto nicht erreicht. Wir liefern überallhin in Ubud und geben dir ein Bike, das zu Ubuds Hügeln passt, nicht nur zum flachen Cruisen.',
      seoTitle: 'Rollerverleih Ubud, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Ubud mit schneller Lieferung ins Zentrum, nach Penestanan, Campuhan und Tegallalang. Kostenlose Lieferung ab einem Monat, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 30 Tagen (1 Monat) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Ubud.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 30 Tagen (1 Monat)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Ubud.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Ubuds Hauptader, die Jalan Raya Ubud, staut sich rund um den Markt und die Monkey Forest Road besonders mittags und am frühen Abend — eine der am stärksten befahrenen einzelnen Straßen Balis außerhalb des Südens. Abseits davon sind die Straßen durch die Reisterrassen und den Campuhan Ridge ruhiger, aber wirklich hügelig, sodass ein etwas stärkeres Bike (ADV oder Xmax) sich dort leichter fährt als ein kleiner Stadtroller.</p>`,
      faqQ1: 'Liefert ihr überallhin in Ubud?',
      faqA1: 'Ja — die Lieferung deckt ganz Ubud ab. Kostenlos ab 30 Tagen (1 Monat), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Ubud" oben. Ubuds Hügel profitieren von etwas mehr Leistung als ein flacher Küstenstadtroller, besonders wenn es weiter zu den Reisterrassen geht.',
    },
    uluwatu: {
      name: 'Uluwatu', prep: 'um',
      h1: 'Roller- & Motorradverleih in Uluwatu',
      intro: 'Uluwatu liegt auf Balis südlichen Kalksteinklippen — Surfspots, Warungs auf der Klippe und die Straße zum Uluwatu-Tempel, weiter verteilt als in den flacheren Gebieten im Norden. Die Straßen hier steigen und winden sich über den Bukit, und die Entfernungen zwischen den Stränden sind größer, als sie auf der Karte aussehen. Wir liefern überallhin um Uluwatu und geben dir ein Bike, das mit den Hügeln klarkommt, nicht nur mit den Strandstraßen.',
      seoTitle: 'Rollerverleih Uluwatu, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Uluwatu mit schneller Lieferung nach Pecatu, Bingin, Balangan und Padang Padang. Kostenlose Lieferung ab 2 Wochen, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 14 Tagen (2 Wochen) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin um Uluwatu.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 14 Tagen (2 Wochen)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin um Uluwatu.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Die Straßen auf der Bukit-Halbinsel rund um Uluwatu sind hügeliger und weiter verteilt als überall sonst auf dieser Liste — von einem Strand zum nächsten (Padang Padang, Bingin, Balangan) bedeutet oft einen echten Anstieg, kein flaches Cruisen. Der Verkehr selbst ist leichter als in Canggu oder Seminyak, aber das Gelände bedeutet, dass ein Roller mit mehr Drehmoment sich deutlich komfortabler fährt.</p>`,
      faqQ1: 'Liefert ihr überallhin um Uluwatu?',
      faqA1: 'Ja — die Lieferung deckt das gesamte Uluwatu-Gebiet ab. Kostenlos ab 14 Tagen (2 Wochen), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Uluwatu" oben. Die Hügel des Bukit profitieren von etwas mehr Leistung als ein flacher Küstenstadtroller.',
    },
    jimbaran: {
      name: 'Jimbaran', prep: 'in',
      h1: 'Roller- & Motorradverleih in Jimbaran',
      intro: 'Jimbaran ist Balis klassische Sonnenuntergangs- und Fischerbucht — ein geschwungener Strand gesäumt von gegrilltem Fisch aus Warungs, zwischen Flughafen und den Bukit-Klippen. Es ist ruhiger und weitläufiger als der belebtere Süden, mit dem Kulturpark GWK und den Zufahrtsstraßen zum Bukit in der Nähe. Wir liefern überallhin in Jimbaran und geben dir ein Bike, das zu deiner geplanten Strecke Richtung Bukit oder Flughafen passt.',
      seoTitle: 'Rollerverleih Jimbaran, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Jimbaran mit schneller Lieferung rund um die Bucht und Richtung GWK. Kostenlose Lieferung ab 2 Wochen, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 14 Tagen (2 Wochen) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Jimbaran.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 14 Tagen (2 Wochen)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Jimbaran.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Jimbaran selbst ist recht entspannt im Vergleich zu den belebteren Surf-Hotspots im Süden — die Straße entlang der Bucht und die Zufahrt zum GWK sind die Hauptadern, der Verkehr nimmt vor allem zum Sonnenuntergang zu, wenn sich die Fisch-Warungs füllen. Ein Roller ist die einfache Art, entlang der Bucht oder hoch zum GWK und zum Bukit zu fahren, ohne nach Parkplätzen zu suchen.</p>`,
      faqQ1: 'Liefert ihr überallhin in Jimbaran?',
      faqA1: 'Ja — die Lieferung deckt ganz Jimbaran ab. Kostenlos ab 14 Tagen (2 Wochen), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Jimbaran" oben. Für die Bucht selbst reicht ein Roller; Richtung Bukit oder GWK geht es mit mehr Leistung leichter.',
    },
    sanur: {
      name: 'Sanur', prep: 'in',
      h1: 'Roller- & Motorradverleih in Sanur',
      intro: 'Sanur ist Balis ruhigster Strandort — eine lange gepflasterte Strandpromenade, seichtes Wasser und ein langsameres Tempo als im belebteren Süden, beliebt bei Familien und bei allen, die mit dem Schnellboot nach Nusa Penida und den Gilis unterwegs sind. Die Straßen sind flacher und weniger überfüllt als die Surf-Hotspots im Süden — ein einfacher Ort, um mit dem Fahren zu beginnen. Wir liefern überallhin in Sanur und geben dir ein Bike, das zu deinen Plänen passt, ob Promenade oder Tagesausflug weiter weg.',
      seoTitle: 'Rollerverleih Sanur, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Sanur mit schneller Lieferung entlang der Promenade und im Hafengebiet. Kostenlose Lieferung ab einer Woche, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 7 Tagen (1 Woche) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Sanur.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 7 Tagen (1 Woche)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Sanur.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Sanur ist einer der ruhigeren Bezirke zum Fahren — die Strandpromenade ist entspannt und rollerfreundlich, und die Straßen ins Landesinnere Richtung Denpasar haben mehr Verkehr als die Küste selbst, aber nichts wie der Stoßzeit-Andrang in Kuta oder Seminyak. Ein angenehmer Ort, um sich ans Fahren auf Bali zu gewöhnen, bevor es weiter weggeht.</p>`,
      faqQ1: 'Liefert ihr überallhin in Sanur?',
      faqA1: 'Ja — die Lieferung deckt ganz Sanur ab. Kostenlos ab 7 Tagen (1 Woche), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Sanur" oben. Sanur selbst ist flach und einfach mit einem Stadtroller; für Tagesausflüge weiter weg ist eine Xmax, V-Strom oder Versys komfortabler.',
    },
    kuta: {
      name: 'Kuta', prep: 'in',
      h1: 'Roller- & Motorradverleih in Kuta',
      intro: 'Kuta ist Balis ursprünglicher Touristenstreifen — Kuta Beach, Legians Nachtleben und Shops, alles dicht und begehbar, aber oft im Stau, besonders nahe der Jalan Legian und der Beachwalk Mall. Ein Roller bleibt der schnellste Weg hindurch, und Kuta liegt von diesen 9 Bezirken am nächsten am Flughafen Ngurah Rai. Wir liefern überallhin in Kuta und geben dir ein Bike, das zu deiner geplanten Strecke jenseits des Streifens passt.',
      seoTitle: 'Rollerverleih Kuta, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Kuta mit schneller Lieferung nach Legian, Tuban und Kuta Beach — nächstgelegener Bezirk zum Flughafen. Kostenlose Lieferung ab einer Woche, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 7 Tagen (1 Woche) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Kuta.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 7 Tagen (1 Woche)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Kuta.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Kuta und Legian gehören zu den am stärksten befahrenen Straßen Balis — die Jalan Legian und die Straßen rund um die Beachwalk Mall stauen sich den größten Teil des Nachmittags und Abends, verschärft durch die Dichte an Fußgängern, Taxis und Lieferrollern. Ein Roller kommt trotzdem schneller durch als ein Auto, und Kutas Nähe zum Flughafen ist praktisch für frühe Ankünfte oder späte Abflüge.</p>`,
      faqQ1: 'Liefert ihr überallhin in Kuta?',
      faqA1: 'Ja — die Lieferung deckt ganz Kuta ab. Kostenlos ab 7 Tagen (1 Woche), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Kuta" oben. Für den Streifen selbst reicht ein Roller; für längere Touren quer durch Bali ist eine Xmax, V-Strom oder Versys komfortabler.',
    },
    'nusa-dua': {
      name: 'Nusa Dua', prep: 'in',
      h1: 'Roller- & Motorradverleih in Nusa Dua',
      intro: 'Nusa Dua ist Balis abgeschlossenes Resortviertel — breite, ruhige Straßen, gepflegte Anlagen und ruhige Strände, ein bewusster Kontrast zum Trubel weiter im Norden. Es ist weitläufiger, als es von innerhalb eines Resorts aussieht, und ein Roller ist die praktische Art, den Strand, den Boothafen oder den Bukit jenseits der Enklave zu erreichen. Wir liefern überallhin in Nusa Dua und geben dir ein Bike, das zu deinen Plänen passt, ob Promenade oder Ausflug weiter nach Bali hinein.',
      seoTitle: 'Rollerverleih Nusa Dua, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Nusa Dua mit schneller Lieferung im ITDC-Resortgebiet und Benoa. Kostenlose Lieferung ab 2 Wochen, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 14 Tagen (2 Wochen) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Nusa Dua.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 14 Tagen (2 Wochen)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Nusa Dua.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Innerhalb der ITDC-Resortenklave sind die Straßen breit, ruhig und gut instand gehalten — wirklich das einfachste Fahren auf dieser Liste. Der Verkehr nimmt vor allem dort zu, wo das Haupttor von Nusa Dua auf die Straße Richtung Benoa und den Rest Balis trifft, und dieser Abschnitt kann sich zu den Pendelzeiten stauen.</p>`,
      faqQ1: 'Liefert ihr überallhin in Nusa Dua?',
      faqA1: 'Ja — die Lieferung deckt ganz Nusa Dua ab. Kostenlos ab 14 Tagen (2 Wochen), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Nusa Dua" oben. Innerhalb der Enklave reicht ein Roller; für längere Touren quer durch Bali ist eine Xmax, V-Strom oder Versys komfortabler.',
    },
    denpasar: {
      name: 'Denpasar', prep: 'in',
      h1: 'Roller- & Motorradverleih in Denpasar',
      intro: 'Denpasar ist Balis Hauptstadt und größte Stadt — Behörden, lokale Märkte und das echte Alltagsleben der Insel, weniger auf Touristen ausgerichtet als die Strandbezirke, aber zentral für alle, die schnell quer über Bali müssen. Der Verkehr auf den Hauptverkehrsadern ist wirklich großstädtisch dicht, und ein Roller ist die praktische Art, schnell voranzukommen. Wir liefern überallhin in Denpasar und geben dir ein Bike, das zu deiner geplanten Strecke passt.',
      seoTitle: 'Rollerverleih Denpasar, Bali — Kostenlose Lieferung & beste Bikes | BikeBaliRent',
      seoDescription: 'Roller- & Motorradverleih in Denpasar mit schneller Lieferung in Balis Hauptstadt. Kostenlose Lieferung ab einer Woche, transparente Preise, 60+ Bikes.',
      deliverySummary: 'Kostenlose Lieferung ab 7 Tagen (1 Woche) Miete · Rp 150.000 Pauschale bei kürzeren Aufenthalten — überallhin in Denpasar.',
      deliveryHtml: `<ul>
<li>Kostenlose Lieferung bei Miete <strong>ab 7 Tagen (1 Woche)</strong>.</li>
<li>Kürzere Mieten: Pauschalgebühr von <strong>Rp 150.000</strong>, überallhin in Denpasar.</li>
<li>Lieferzeit und genauer Treffpunkt werden nach der Buchung per WhatsApp bestätigt.</li>
<li>Wir liefern aus einem zentralen Depot in Kerobokan.</li>
</ul>
<p>Wir können fast jederzeit liefern — Lieferungen am Abend oder in der Nacht außerhalb der üblichen Zeiten sind gegen Aufpreis möglich und müssen vorher abgesprochen werden.</p>`,
      gettingAroundHtml: `<p>Denpasar hat den dichtesten, wirklich großstädtischsten Verkehr aller Bezirke auf dieser Liste — die Hauptadern sind fast den ganzen Arbeitstag über wirklich verstopft, eher wie die Stoßzeit einer regionalen Hauptstadt als der nachmittägliche Stau eines Strandorts. Ein Roller ist hier weniger optional als überall sonst — sich durch den langsamen Verkehr zu schlängeln ist oft die einzig realistische Art, schnell voranzukommen.</p>`,
      faqQ1: 'Liefert ihr überallhin in Denpasar?',
      faqA1: 'Ja — die Lieferung deckt ganz Denpasar ab. Kostenlos ab 7 Tagen (1 Woche), Rp 150.000 Pauschale bei kürzeren Aufenthalten.',
      faqQ4: 'Reicht ein Roller, oder sollte ich etwas Größeres mieten?',
      faqA4: 'Kommt auf deine Pläne an — siehe „Welches Bike passt am besten zu Denpasar" oben. Für Stadtfahrten reicht ein Roller; für längere Touren quer durch Bali ist eine Xmax, V-Strom oder Versys komfortabler.',
    },
  },
};
