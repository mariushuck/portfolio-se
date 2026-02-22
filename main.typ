#import "@preview/clean-dhbw:0.3.1": *
#import "glossary.typ": glossary-entries

#show: clean-dhbw.with(
  title: "Re-Engineering und Architekturanalyse eines Chat-Socket-Systems",
  authors: (
    (name: "Moritz Glück", student-id: "7654321", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Marius Huck", student-id: "3391238", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Felix Mehler", student-id: "7654321", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Selina Wahl", student-id: "7654321", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik")
  ),
  
  type-of-thesis: "Portfolioprüfung",
  at-university: true, 
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, 
  language: "de", 
  supervisor: (university: "Prof. Dr. Roland Schätzle"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Karlsruhe",
  university-short: "DHBW",
)

= Einleitung

Das vorliegende Dokument dokumentiert die Architekturanalyse und das Re-Engineering des Projekts "chat-socket". Ziel ist es, die bestehende Struktur zu verstehen, Entwurfsmuster zu identifizieren und die Softwarequalität gemäß ISO 25010 zu bewerten.

== Projektbeschreibung

Das analysierte System "chat-socket" ist eine in Java realisierte Client-Server-Applikation, die grundlegende Chat-Funktionalitäten wie privaten Chat, Benutzerregistrierung und Statusanzeigen bereitstellt. Technisch basiert das Projekt auf TCP-Sockets für die Netzwerkkommunikation und nutzt Java-Serialisierung sowie JSON für den Datenaustausch. Ein besonderes Merkmal ist die Unterstützung zweier unterschiedlicher UI-Technologien (JavaFX und Swing). Die Verwaltung der Abhängigkeiten und der Build-Prozess werden über Maven gesteuert.

= Erläuterung der Komponentendiagramme

= Gesamtüberblick der Systemarchitektur

Das System ist als klassisches *Client-Server-System* mit TCP-Socket-Kommunikation aufgebaut. Sowohl Client als auch Server sind in logisch getrennte Komponenten gegliedert, die jeweils funktionale Verantwortlichkeiten bündeln.

Architektonisch lässt sich das System in drei logische Ebenen unterteilen:
- *View-Schicht (UI)*
- *Presenter-Schicht (Koordination/UI-Logik)*
- *Model-Schicht (fachliche Logik + Kommunikation)*

Diese Trennung ist sowohl im Client als auch im Server konsequent umgesetzt.

= Server – Interaktion der Komponenten

== ServerView, ServerPresenter und ServerViewPlatform

Der *ServerPresenter* vermittelt zwischen Benutzeroberfläche und Serverlogik. Er verarbeitet Benutzereingaben wie Start- und Stop-Aktionen und manipuliert die View entsprechend.

== ServerModel – zentrale Verarbeitungsschicht

Das *ServerModel* bündelt die gesamte fachliche Serverlogik, inklusive Netzwerkkommunikation, Request-Verarbeitung und Account-Verwaltung.

== Kommunikationsschnittstelle zum Client

Die Kommunikationsschnittstelle wird durch *TCPServerSocket* und *SocketWorker* realisiert. Für jede Verbindung wird ein eigener *SocketWorker* erzeugt.

== RequestRouter und RequestHandler

Eingehende Requests werden an den *RequestRouter* übergeben, der die Verarbeitung an einen passenden *RequestHandler* delegiert.

== AccountManager und JSONAccountStorage

Die Account-Verwaltung ist im *AccountManager* gekapselt, wobei die Persistenz über den *JSONAccountStorage* in einer JSON-Datei erfolgt.

= Client – Interaktion der Komponenten

== ClientView, ClientPresenter und ClientViewPlatform

Die *ClientView* umfasst spezialisierte Oberflächen wie Login-, Chat- und FriendlistView. Die *ClientPresenter*-Komponente besteht aus Unter-Presentern, die auf Benutzeraktionen reagieren.

== ClientModel – zentrale Clientlogik

Das *ClientModel* enthält den `SocketClient`, `ResponseHandler` und den `ChattingManagerImpl` zur Verwaltung des lokalen Zustands.

== SocketClient – Verbindung und Nachrichtenfluss

Der *SocketClient* stellt die TCP-Verbindung her und delegiert empfangene Antworten an passende `ResponseHandler`.

= Zusammenspiel zwischen Client und Server

Zusammenfassend erfolgt der Ablauf über den Aufbau einer TCP-Verbindung, den Austausch von Requests und Responses sowie die anschließende Aktualisierung von Presenter und View auf beiden Seiten.

= Abstraktionsebene der Diagramme

Die Komponentendiagramme stellen bewusst eine *abstrahierte Sicht* dar, um Verantwortlichkeiten und Kommunikationsflüsse verständlich zu machen.

= Identifikation von Design Pattern

In diesem Kapitel werden die im System identifizierten Entwurfsmuster detailliert beschrieben. Diese dienen der schrittweisen hierarchischen Verfeinerung der Architektur.

== Creational Pattern: Factory Method
Das System setzt Fabrikmuster ein, um die Instanziierung von Objekten zu zentralisieren und vom restlichen Code zu entkoppeln.

- *Zentrale Handler-Erzeugung*: In den Klassen `ResponseHandlerFactory` (Client) und `RequestHandlerFactory` (Server) wird anhand eines Typs (z. B. `RequestCode`) entschieden, welcher konkrete Handler erzeugt wird. Dadurch muss die Netzwerkkomponente die konkreten Handler-Klassen nicht kennen.
- *Abstraktion der UI-Technologie*: Die `ViewFactory` definiert eine Schnittstelle zur Erzeugung aller Fenster. Konkrete Implementierungen wie `JavaFxViewFactory` liefern plattformspezifische Objekte zurück, was den Austausch der UI-Technologie ohne Änderung der Presenter ermöglicht.

== Behavioral Pattern: Observer (Event-Bus)
Zur Kommunikation zwischen den entkoppelten Komponenten wird eine ereignisbasierte Architektur genutzt, die auf dem Google Guava `EventBus` basiert.

- *Ereignisgesteuerter Nachrichtenfluss*: Wenn der `SocketClient` eine Nachricht empfängt, wird ein `ChatMessageReceivedEvent` auf den Bus gepostet.
- *Lose Kopplung*: Komponenten wie der `ChatPresenter` registrieren sich via `@Subscribe` für spezifische Ereignisse. Der Sender benötigt keine Referenz auf den Empfänger, was die Modularität erhöht und einen „Big Ball of Mud“ verhindert.

== Architectural Pattern: Model-View-Presenter (MVP)
Das System folgt dem MVP-Muster, um Präsentationslogik strikt von der Darstellung zu trennen.

- *Der Presenter als Dialogkern*: Der `ChatPresenter` bildet den Dialogkern. Er steuert die Interaktionen und kommuniziert mit dem Model.
- *Die Passive View*: Die Benutzeroberfläche ist als „Passive View“ realisiert. Sie definiert lediglich eine Schnittstelle (`ChatView`), über die der Presenter Daten übergibt.
- *Schnittstellenbasierte Trennung*: Der Presenter arbeitet ausschließlich gegen das Interface `ChatView`, was den Dialogkern technikneutral macht.

= Fazit

Die Architekturanalyse des "chat-socket"-Systems verdeutlicht eine konsequente Trennung von Belangen (Separation of Concerns), die für ein Projekt dieser Größenordnung bemerkenswert strukturiert umgesetzt wurde. Durch die Anwendung des Model-View-Presenter (MVP)-Musters in Kombination mit dem Factory-Design-Pattern ist es den Entwicklern gelungen, eine hohe Austauschbarkeit der UI-Komponenten zu gewährleisten. Die Tatsache, dass das System nahtlos zwischen Swing und JavaFX wechseln kann, ohne die zugrunde liegende Programmlogik zu tangieren, unterstreicht die Flexibilität der Architektur.

Ein wesentlicher Erfolgsfaktor für die Wartbarkeit des Systems ist der Einsatz eines ereignisbasierten Kommunikationsmodells über den Guava EventBus. Diese lose Kopplung minimiert direkte Abhängigkeiten zwischen den Komponenten und erleichtert die Erweiterbarkeit um neue Funktionen, da neue Listener (z. B. für zusätzliche Chat-Features) ohne tiefgreifende Änderungen am bestehenden Code integriert werden können.