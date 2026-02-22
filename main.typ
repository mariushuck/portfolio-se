#import "@preview/clean-dhbw:0.3.1": *
#import "glossary.typ": glossary-entries

#show: clean-dhbw.with(
  title: "Evaluation von Typst zur Erstellung einer Abschlussarbeit",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course: "TINF22B2", course-of-studies: "Informatik", company: (
      (name: "ABC GmbH", post-code: "76131", city: "Karlsruhe")
    )),
    // (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
    //   (name: "ABC S.L.", post-code: "08005", city: "Barcelona", country: "Spain")
    // )),
  ),
  type-of-thesis: "Bachelorarbeit",
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (company: "John Appleseed", university: "Prof. Dr. Daniel Düsentrieb"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Karlsruhe",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/clean-dhbw)
)

// Edit this content to your liking

= Einleitung

#lorem(100)

#lorem(80)

#lorem(120)

= Erläuterungen

Im folgenden werden einige nützliche Elemente und Funktionen zum Erstellen von Typst-Dokumenten mit diesem Template erläutert.

== Ausdrücke und Abkürzungen

Verwende die `gls`-Funktion, um Ausdrücke aus dem Glossar einzufügen, die dann dorthin verlinkt werden. Ein Beispiel dafür ist: 

Im diesem Kapitel wird eine #gls("Softwareschnittstelle") beschrieben. Man spricht in diesem Zusammenhang auch von einem #gls("API"). Die Schnittstelle nutzt Technologien wie das #gls("HTTP").

Das Template nutzt das `glossarium`-Package für solche Glossar-Referenzen. In der zugehörigen #link("https://typst.app/universe/package/glossarium/", "Dokumentation") werden noch weitere Varianten für derartige Querverweise gezeigt. Dort ist auch im Detail erläutert, wie das Glossar aufgebaut werden kann.


= Erläuterung der Komponentendiagramme

== 1. Gesamtüberblick der Systemarchitektur

Das System ist als klassisches *Client-Server-System* mit TCP-Socket-Kommunikation aufgebaut. Sowohl Client als auch Server sind in logisch getrennte Komponenten gegliedert, die jeweils funktionale Verantwortlichkeiten bündeln.

Die Komponentendiagramme stellen dabei *abstrahierte Module* dar. Einzelne Komponenten fassen mehrere Klassen aus dem Repository zusammen. Beispielsweise steht »RequestHandler« im Serverdiagramm für eine Gruppe konkreter Handler-Klassen, während »ResponseHandler« im Clientdiagramm mehrere spezifische Antwortverarbeiter repräsentiert.

Architektonisch lässt sich das System in drei logische Ebenen unterteilen:

- *View-Schicht (UI)*
- *Presenter-Schicht (Koordination/UI-Logik)*
- *Model-Schicht (fachliche Logik + Kommunikation)*

Diese Trennung ist sowohl im Client als auch im Server konsequent umgesetzt.

== 2. Server – Interaktion der Komponenten

=== 2.1 ServerView, ServerPresenter und ServerViewPlatform

Die Komponente *ServerView* umfasst die grafischen Oberflächen zur Steuerung des Servers (z.\ B. MainView und LogView). Der *ServerPresenter* vermittelt zwischen Benutzeroberfläche und Serverlogik. Er verarbeitet Benutzereingaben wie Start- und Stop-Aktionen und manipuliert die View entsprechend (z.\ B. Statusanzeigen).

Die *ServerViewPlatform* übernimmt infrastrukturelle Aufgaben wie Initialisierung der UI und Zusammenführen von View und Presenter. Sie ist keine fachliche Komponente, sondern stellt lediglich die technische Umgebung bereit.

Die Interaktion ist wie folgt:

1. Der Benutzer startet oder stoppt den Server über die View.
2. Der Presenter verarbeitet diese Aktion.
3. Der Presenter löst im ServerModel entsprechende Start- oder Stop-Vorgänge aus.
4. Statusänderungen werden zurück an die View propagiert.

=== 2.2 ServerModel – zentrale Verarbeitungsschicht

Das *ServerModel* bündelt die gesamte fachliche Serverlogik. Es enthält:

- Netzwerkkommunikation
- Request-Verarbeitung
- Account-Verwaltung
- Weiterleitung von Nachrichten

Diese Schicht ist unabhängig von der UI.

=== 2.3 Kommunikationsschnittstelle zum Client

Die eigentliche Kommunikationsschnittstelle zum Client wird durch die Kombination aus:

- *TCPServerSocket*
- *SocketWorker*

realisiert.

Der TCPServerSocket akzeptiert eingehende Verbindungen. Für jede Verbindung wird ein eigener *SocketWorker* erzeugt.

Der SocketWorker übernimmt:

- Empfang von Requests vom Client
- Weitergabe der Requests an die Verarbeitungslogik
- Versenden von Responses zurück zum Client

Damit bildet der SocketWorker die operative Schnittstelle zwischen Netzwerk und Serverlogik.

=== 2.4 RequestRouter und RequestHandler

Eingehende Requests werden nicht direkt verarbeitet, sondern zunächst an den *RequestRouter* übergeben.

Der RequestRouter:

1. Analysiert den Typ des Requests.
2. Delegiert die Verarbeitung an einen passenden *RequestHandler*.

Die Komponente »RequestHandler« im Diagramm fasst mehrere konkrete Handler zusammen, etwa für:

- Login
- Registrierung
- Freundesliste
- Profilaktualisierung
- Chatnachrichten

Diese Abstraktion reduziert die Komplexität des Diagramms, da die konkrete Klassenstruktur separat dokumentiert wird.

Nach der Verarbeitung erzeugt der jeweilige Handler eine Response, die über den SocketWorker an den Client zurückgesendet wird.

=== 2.5 AccountManager und JSONAccountStorage

Die Account-Verwaltung ist im *AccountManager* gekapselt. Diese Komponente übernimmt:

- Prüfung von Login-Daten
- Registrierung neuer Nutzer
- Änderung von Profildaten
- Verwaltung des Online-Status

Die Persistenz erfolgt über *JSONAccountStorage*, das Accounts in einer JSON-Datei speichert.

Im Diagramm wird diese Beziehung über die Schnittstellen »FindAccounts« und »EditAccounts« abstrahiert dargestellt. Dadurch wird deutlich, dass der AccountManager sowohl lesende als auch schreibende Operationen ausführt, ohne die konkrete Implementierung offenzulegen.

=== 2.6 Nachrichtenweiterleitung

Beim Versenden einer Chatnachricht läuft die Interaktion wie folgt ab:

1. Ein Client sendet eine ChatMessage.
2. Der SocketWorker empfängt den Request.
3. Der RequestRouter leitet an den ChatMessageRequestHandler weiter.
4. Der Handler bestimmt den Empfänger.
5. Der entsprechende SocketWorker des Empfängers sendet die Nachricht an dessen Client.

Der Server agiert hier als Vermittler zwischen zwei unabhängigen Clientverbindungen.

== 3. Client – Interaktion der Komponenten

=== 3.1 ClientView, ClientPresenter und ClientViewPlatform

Die *ClientView* umfasst mehrere spezialisierte Oberflächen:

- LoginView
- ChatView
- FriendlistView
- ProfileView
- ConnectionView

Diese Views enthalten keine Geschäftslogik.

Die *ClientPresenter*-Komponente besteht aus mehreren Unter-Presentern (z.\ B. LoginPresenter, ChatPresenter). Sie übernimmt:

- Reaktion auf Benutzeraktionen
- Anforderung von Daten aus dem Model
- Aktualisierung der Views

Die *ClientViewPlatform* stellt – analog zur ServerViewPlatform – die technische UI-Infrastruktur bereit.

Die Interaktion folgt diesem Prinzip:

- View sendet Benutzereingabe an Presenter.
- Presenter löst fachliche Aktion im ClientModel aus.
- Model liefert Daten zurück.
- Presenter aktualisiert View.

=== 3.2 ClientModel – zentrale Clientlogik

Das *ClientModel* enthält:

- SocketClient (Netzwerkkommunikation)
- ResponseHandler
- ChattingManagerImpl
- UserProfile
- ManagedFriends

Diese Komponenten arbeiten zusammen, um Serverantworten zu verarbeiten und den lokalen Zustand zu verwalten.

=== 3.3 SocketClient – Verbindung und Nachrichtenfluss

Der *SocketClient* stellt die Verbindung zum Server her. Er übernimmt:

- Aufbau der TCP-Verbindung
- Senden von Requests
- Empfang von Responses

Requests werden vom Presenter indirekt ausgelöst. Responses werden vom SocketClient empfangen und an passende ResponseHandler delegiert.

Damit entspricht die Struktur auf Client-Seite spiegelbildlich der Serverstruktur (Router/Handler-Prinzip).

=== 3.4 ResponseHandler

Die Komponente »ResponseHandler« fasst mehrere konkrete Antwortverarbeiter zusammen.

Je nach Response-Typ werden unterschiedliche Aktionen ausgelöst, etwa:

- Aktualisierung der Freundesliste
- Anzeige einer Fehlermeldung
- Öffnen eines Chatfensters
- Aktualisierung des Benutzerprofils

Durch diese Struktur bleibt der SocketClient selbst generisch, während die fachliche Reaktion modular organisiert ist.

=== 3.5 ChattingManagerImpl und Zustandsverwaltung

Der *ChattingManagerImpl* verwaltet:

- Aktive Chats
- Freundesstatus
- Verarbeitung eingehender Chatnachrichten

Er stellt sicher, dass bei eingehender Nachricht gegebenenfalls ein Chatfenster geöffnet wird und die Nachricht korrekt angezeigt wird.

Die Komponente *UserProfile* repräsentiert den aktuell angemeldeten Benutzer und dient als zentrale Datenquelle für Presenter und View.

== 4. Zusammenspiel zwischen Client und Server

Zusammenfassend ergibt sich folgender Kommunikationsablauf:

1. Der Client baut eine TCP-Verbindung auf.
2. Der Server akzeptiert die Verbindung und erzeugt einen SocketWorker.
3. Der Client sendet Requests (z.\ B. Login, ChatMessage).
4. Der Server verarbeitet Requests über Router und Handler.
5. Der Server sendet Responses zurück.
6. Der Client verarbeitet Responses über ResponseHandler.
7. Presenter und View werden aktualisiert.

Die Serverkomponenten sind dabei vollständig von der UI entkoppelt. Der Client wiederum ist klar zwischen UI und Netzwerklogik getrennt.

== 5. Abstraktionsebene der Diagramme

Die Komponentendiagramme stellen bewusst eine *abstrahierte Sicht* dar:

- Mehrere konkrete Klassen sind zu logischen Modulen zusammengefasst.
- Interne Verarbeitungsdetails werden ausgelassen.
- Entwurfsmuster (z.\ B. Factory, Event-basierte Kommunikation) werden hier nicht im Detail erläutert, da sie in gesonderten Diagrammen behandelt werden.

Ziel der Diagramme ist es, die *Verantwortlichkeiten und Abhängigkeiten der Hauptkomponenten* darzustellen und die Kommunikationsflüsse zwischen ihnen verständlich zu machen.

== Listen

Es gibt Aufzählungslisten oder nummerierte Listen:

- Dies
- ist eine
- Aufzählungsliste

+ Und
+ hier wird
+ alles nummeriert.

== Abbildungen und Tabellen

Abbildungen und Tabellen (mit entsprechenden Beschriftungen) werden wie folgt erstellt.

=== Abbildungen

#figure(caption: "Eine Abbildung", image(width: 4cm, "assets/ts.svg"))

=== Tabellen

#figure(
  caption: "Eine Tabelle",
  table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
)<table>

== Programm Quellcode

Quellcode mit entsprechender Formatierung wird wie folgt eingefügt:

#figure(
  caption: "Ein Stück Quellcode",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)


== Verweise

Für Literaturverweise verwendet man die `cite`-Funktion oder die Kurzschreibweise mit dem \@-Zeichen:
- `#cite(form: "prose", <iso18004>)` ergibt: \ #cite(form: "prose", <iso18004>)
- Mit `@iso18004` erhält man: @iso18004

Tabellen, Abbildungen und andere Elemente können mit einem Label in spitzen Klammern gekennzeichnet werden (die Tabelle oben hat z.B. das Label `<table>`). Sie kann dann mit `@table` referenziert werden. Das ergibt im konkreten Fall: @table

= Fazit

#lorem(50)

#lorem(120)

#lorem(80)