#import "@preview/clean-dhbw:0.3.1": *
#import "glossary.typ": glossary-entries

#show: clean-dhbw.with(
  title: "Re-Engineering und Architekturanalyse eines Chat-Socket-Systems",
  authors: (
    (name: "Moritz Glück", student-id: "7848413", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Marius Huck", student-id: "3391238", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Felix Mehler", student-id: "8564068", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik"),
    (name: "Celina Wahl", student-id: "6532414", course: "WWI24B2", course-of-studies: "Wirtschaftsinformatik")
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
city: "Karlsruhe",
)

= Einleitung

Das vorliegende Dokument dokumentiert die Architekturanalyse und das Re-Engineering des Projekts "chat-socket". Ziel ist es, die bestehende Struktur zu verstehen, Entwurfsmuster zu identifizieren und die Softwarequalität gemäß ISO 25010 zu bewerten.

== Projektbeschreibung

Das analysierte System "chat-socket" ist eine in Java realisierte Client-Server-Applikation, die grundlegende Chat-Funktionalitäten wie privaten Chat, Benutzerregistrierung und Statusanzeigen bereitstellt. Technisch basiert das Projekt auf TCP-Sockets für die Netzwerkkommunikation und nutzt Java-Serialisierung sowie JSON für den Datenaustausch. Ein besonderes Merkmal ist die Unterstützung zweier unterschiedlicher UI-Technologien (JavaFX und Swing). Die Verwaltung der Abhängigkeiten und der Build-Prozess werden über Maven gesteuert.

= Deployment-Diagramm – Verteilungssicht für „chat-socket“

#image("/assets/DeploymentDiagram.svg", width: 85%)

== Überblick
Das Deployment-Diagramm beschreibt die physische Verteilung der Chat-Anwendung `chat-socket` auf verschiedene Rechner. Die Anwendung besteht aus einem Client und einem Server, die beide aus demselben Artefakt (`chatsocket.jar`) gestartet werden, jedoch in unterschiedlichen Betriebsmodi ausgeführt werden. Die Kommunikation erfolgt über eine TCP/IP-Verbindung auf Port 3393.

== Knoten und Ausführungsumgebungen

=== Client-Knoten
Der Client wird auf einem Endgerät wie einem PC oder Laptop ausgeführt. Dieses Gerät wird im Deployment-Diagramm als «device» *Client* dargestellt. Auf diesem Knoten befindet sich die «executionEnvironment» *Java SE 8 Runtime*, welche die notwendige Ausführungsumgebung für die Anwendung bereitstellt. Sie umfasst die Java Virtual Machine (JVM) sowie die Standardbibliotheken, die zur Ausführung des Programms erforderlich sind. Innerhalb dieser Laufzeitumgebung wird das «artifact» `chatsocket.jar` ausgeführt. Dabei handelt es sich um die ausführbare Anwendung, die im Client-Modus mit dem Parameter `--mode=client` gestartet wird. In diesem Modus stellt die Anwendung die grafische Benutzeroberfläche sowie die gesamte Client-Logik bereit, wie beispielsweise den Verbindungsaufbau zum Server, die Benutzeranmeldung oder das Senden und Empfangen von Nachrichten.

=== Server-Knoten
Der Server wird auf einem separaten Rechner oder einem dedizierten Server-System ausgeführt. Dieser wird im Deployment-Diagramm als «device» *Server* modelliert. Wie auch beim Client befindet sich auf diesem Knoten die «executionEnvironment» *Java SE 8 Runtime*. Sie stellt die notwendige Laufzeitumgebung zur Verfügung und ermöglicht die Ausführung der serverseitigen Anwendung. Innerhalb dieser Laufzeitumgebung wird ebenfalls das «artifact» `chatsocket.jar` gestartet. Die Anwendung wird hier mit dem Parameter `--mode=server` gestartet und übernimmt damit die Rolle des zentralen Servers im System. In diesem Modus stellt sie einen TCP-Server bereit, der auf einem definierten Port auf eingehende Client-Verbindungen wartet. Darüber hinaus übernimmt der Server die Benutzerverwaltung sowie die Verarbeitung und Weiterleitung von Nachrichten zwischen den verbundenen Clients. Durch den Einsatz von Multithreading können mehrere Client-Verbindungen gleichzeitig verarbeitet werden.

== Kommunikationspfad
Zwischen Client und Server besteht eine Netzwerkverbindung, die im Deployment-Diagramm als «communicationPath» *TCP/IP Port 3393* dargestellt wird. Diese Verbindung erfolgt über das TCP/IP-Protokoll auf dem Port 3393. Der Server lauscht auf dem festgelegten Port 3393 und wartet auf eingehende Client-Verbindungen. Der Client baut über diesen Port eine TCP/IP-Verbindung zum Server auf. Über diese Verbindung werden alle Nachrichten, Statusinformationen und Benutzeranmeldungen übertragen. Die Kommunikation erfolgt über JSON-Nachrichten und Java-Objekte. Dieser Kommunikationspfad bildet die Grundlage für alle zentralen Funktionen der Anwendung, wie den Nachrichtenaustausch, die Benutzeranmeldung sowie die Übertragung von Statusinformationen.

== Begründung der Modellierungsentscheidungen
Die Verteilungssicht konzentriert sich auf die physischen Ausführungsumgebungen, die eingesetzten Artefakte sowie die Kommunikationsbeziehungen zwischen den beteiligten Systemteilen. Persistente Dateien wie `app.json` oder `user.json` werden in diesem Kontext nicht als eigene Artefakte modelliert. Dies liegt daran, dass sie lokal im Dateisystem abgelegt werden, keine eigenständigen Komponenten darstellen, nicht über das Netzwerk verteilt werden und keine eigene Ausführungsumgebung benötigen. Sie dienen lediglich als lokale Datenspeicher und sind daher für die Darstellung der Deployment-Struktur nicht relevant.

= Erläuterung der Komponentediagramme der Chat-Socket-Anwedung

== Überblick über die Systemarchitektur

Die vorliegenden Komponentendiagramme beschreiben die Architektur einer Client-Server-basierten Chat-Anwendung. Das zugrundeliegende Repository implementiert eine socketbasierte Kommunikation zwischen einem Desktop-Client und einem Server. Beide Seiten sind klar strukturiert und folgen einer schichtenartigen Architektur mit klarer Trennung von Präsentation, Anwendungslogik und technischer Infrastruktur.
Die Diagramme abstrahieren von einzelnen Klassen und fassen funktional zusammengehörige Komponenten zusammen. Dadurch entsteht ein verständliches Architekturmodell, das die wesentlichen Verantwortlichkeiten und Abhängigkeiten sichtbar macht.

Grundsätzlich besteht das System aus:
- einer Client-Anwendung mit GUI
- einem Server mit Request-Verarbeitung
- einer TCP-basierten Kommunikationsschnittstelle
- einer JSON-basierten Persistenz für Benutzerkonten

== Client Architektur

#image("/assets/ClientArchitecture.jpg", width: 100%)

=== ClientView (Präsentationsschicht)

Die ClientView-Komponente umfasst mehrere spezialisierte Views. Diese Komponenten sind ausschließlich für die Darstellung zuständig. Sie enthalten keine Geschäftslogik, sondern stellen Benutzereingaben bereit und zeigen Daten an. Technisch basieren sie auf einer GUI-Plattform (abstrahiert als ClientViewPlatform).
Die View kennt keine Netzwerkdetails und keine Geschäftslogik. Sie kommuniziert ausschließlich über definierte Schnittstellen mit dem Presenter.

=== ClientPresenter (Vermittlerschichte)

Die Presenter-Komponenten (z. B. ChatPresenter, LoginPresenter, ProfilePresenter) koordinieren Benutzerinteraktionen. 
Sie verarbeiten Benutzereingaben und manipulieren die View.
Beispielsweise ruft der ChatPresenter beim Senden einer Nachricht den ChattingManager auf, welcher die Nachricht technisch vorbereitet und über den SocketClient versendet.
Die Presenter-Schicht vermittelt somit zwischen GUI und Anwendungslogik.

=== ClientModel (Anwendungslogik)

Das ClientModel enthält die zentrale Client-Logik. Der SocketClient ist die technische Schnittstelle zum Server. Er sendet Request-Objekte, empfängt Response-Objekte und delegiert eingehende Responses an passende Handler
Er kapselt sämtliche Netzwerkkommunikation (TCP, Streams) und trennt die restliche Client-Logik von technischen Details.

Für jede Response-Art existiert ein spezialisierter Handler (z. B. LoginResponseHandler, ChatMessageResponseHandler). Hier werden DTO-Daten extrahiert, das Model aktualisiert und Server-Responses interpretiert. Dadurch wird eine saubere Trennung der Response-Verarbeitung erreicht.

Ein weiter Bestandteil ist der Chattingmanager. Er ist ist eine zentrale Koordinationskomponente für Chat-Nachrichten und verbindet falchlichen Zustand mit technischer Kommunikation. Dafür wird er im ChatMessageResponseHandler implementiert. Zusätzlich steuert die Komponente den ChatPresenter.

ManagedFriends und UserProfile verwalten lokale Anwendungsdaten wie Freundeslisten, Profilinformationen, aktuellen Benutzerzustand. Sie enthalten keine Netzwerk- oder GUI-Logik.



== Server Architektur
#image("/assets/ServerArchitecture.jpg", width: 100%)
=== ServerView (Präsentationsschicht)
Die ServerView-Komponente umfasst die MainView und die LogView.�Diese Komponenten dienen ausschließlich der Darstellung und Steuerung des Servers. Über die Benutzeroberfläche kann der Server gestartet und gestoppt sowie Log-Ausgaben eingesehen werden.
Die View enthält keine Geschäftslogik und verarbeitet keine Netzwerkkommunikation. Sie kommuniziert ausschließlich über definierte Schnittstellen mit dem ServerPresenter. Die technische GUI-Plattform wird dabei über die Komponente ServerViewPlatform abstrahiert.

=== ServerPresenter (Vermittlerschicht)
Der ServerPresenter übernimmt die Koordination zwischen Benutzeroberfläche und Serverlogik. Er verarbeitet Benutzereingaben wie Start- und Stop-Befehle und stößt entsprechende Aktionen im System an.
Beim Starten des Servers wird beispielsweise der SocketWorker initialisiert und die Netzwerkkommunikation aktiviert. Beim Stoppen werden entsprechende Shutdown-Mechanismen ausgelöst.
Die Presenter-Schicht vermittelt somit zwischen GUI und technischer Infrastruktur und kapselt die Steuerungslogik des Servers.

=== ServerModel (Anwendungs- und Verarbeitungsschicht)
Das ServerModel enthält die zentrale Logik zur Verarbeitung eingehender Client-Anfragen.
Ein zentraler Bestandteil ist der SocketWorker. Diese Komponente verarbeitet eingehende Verbindungen und liest Requests von Clients. Sie stellt damit die technische Kommunikationsschnittstelle zum Client dar und kapselt sämtliche TCP-basierte Netzwerkoperationen.

Eingehende Requests werden an den RequestRouter weitergeleitet. Der RequestRouter analysiert den Request-Typ und delegiert die Verarbeitung an den passenden RequestHandler.

Für jede Request-Art existiert ein spezialisierter Handler (z. B. LoginRequestHandler, RegisterRequestHandler, ChatMessageRequestHandler). Diese Komponenten interpretieren die eingehenden Request-Daten, führen die entsprechende fachliche Operation aus und erzeugen eine passende Response. Anschließend wird die Response über den SocketWorker an den Client zurückgesendet.

Dadurch entsteht eine klar strukturierte Dispatch-Architektur, bei der neue Request-Typen durch Hinzufügen eines weiteren Handlers ergänzt werden können.

Der AccountManager kapselt die fachliche Logik für die Verwaltung von Benutzerkonten. Dazu gehören zum Beispiel die Registrierung neuer Benutzer und Login-Validierung.
Diese Komponente enthält keine Netzwerklogik und ist von der Kommunikationsschicht entkoppelt. Sie stellt die eigentliche Geschäftslogik des Servers dar.

=== JSONAccountStorage (Persistenzschicht)
Die Persistenz erfolgt über JSON-Dateien. Die Komponente JSONAccountStorage übernimmt das Laden und Speichern der Benutzerkonten. Dabei werden Serialisierungs- und Deserialisierungsmechanismen verwendet, um die Daten zwischen Objektstruktur und Datei darzustellen.
Diese Komponente kapselt sämtliche Datei- und IO-Operationen und trennt damit Persistenz von Geschäftslogik.
= Identifikation von Design Pattern

In diesem Kapitel werden die im System identifizierten Entwurfsmuster detailliert beschrieben. Diese dienen der schrittweisen hierarchischen Verfeinerung der Architektur und gewährleisten eine saubere Trennung von Zuständigkeiten.

== Creational Pattern: Factory Method

#image("/assets/Factory.svg", width: 35%)

Das System setzt das Fabrikmuster (Factory Method) ein, um die Instanziierung von Objekten zu zentralisieren und den aufrufenden Code von konkreten Implementierungen zu entkoppeln.

- *Zentrale Handler-Erzeugung (Open-Closed Principle)*: Die Klassen `ResponseHandlerFactory` (Client) und `RequestHandlerFactory` (Server) kapseln die Logik zur Objekterzeugung. Anhand eines Typs (z. B. `RequestCode`) wird dynamisch entschieden, welcher konkrete Handler erzeugt wird. Dies erlaubt es, das System um neue Funktionen zu erweitern, ohne die bestehende Netzwerkkomponente modifizieren zu müssen.
- *Abstraktion der UI-Technologie*: Die `ViewFactory` definiert eine abstrakte Schnittstelle zur Erzeugung aller UI-Komponenten. Die konkrete `JavaFxViewFactory` liefert plattformspezifische Objekte zurück. Da die Presenter ausschließlich gegen das Interface der Factory arbeiten, bleibt die Anwendungslogik unabhängig von der zugrunde liegenden Grafikbibliothek (z. B. JavaFX, Swing oder fiktive Web-UIs).

== Behavioral Pattern: Observer (Event-Bus)

#image("/assets/Behavioral.svg", width: 80%)

Zur Kommunikation zwischen den entkoppelten Komponenten wird eine ereignisbasierte Architektur genutzt, die auf dem Google Guava `EventBus` basiert. Dies stellt eine moderne Implementierung des Observer-Musters dar.

- *Ereignisgesteuerter Nachrichtenfluss*: Sobald der `SocketClient` ein Datenpaket empfängt, wird dieses in ein Event-Objekt (z. B. `ChatMessageReceivedEvent`) transformiert und auf den Bus gepostet. Der Sender kennt dabei weder die Anzahl noch die Art der Empfänger.
- *Lose Kopplung und Modularität*: Komponenten wie der `ChatPresenter` registrieren sich mittels der `@Subscribe`-Annotation für spezifische Ereignisse. Diese lose Kopplung verhindert eine starre Objekt-Hierarchie (Vermeidung eines „Big Ball of Mud“) und ermöglicht es, neue Funktionalitäten (wie Logging oder Statistik-Module) einfach als weitere Subscriber hinzuzufügen, ohne den bestehenden Code zu beeinflussen.

== Architectural Pattern: Model-View-Presenter (MVP)

#image("/assets/Architectural.svg", width: 80%)

Das System folgt dem MVP-Muster, um die Präsentationslogik strikt von der visuellen Darstellung zu trennen. Dies bietet ein Höchstmaß an Flexibilität bei der Wahl der UI-Technologie.

- *Der Presenter als Dialogkern*: Der `ChatPresenter` fungiert als zentraler Koordinator. Er verarbeitet die vom Event-Bus eingehenden Daten, bereitet sie für die Anzeige auf und reagiert auf Benutzereingaben der View.
- *Die Passive View*: Die Benutzeroberfläche ist konsequent als „Passive View“ realisiert. Das bedeutet, die View (z. B. `ChatViewImpl`) enthält keinerlei Programmlogik, sondern bietet lediglich Methoden zur Manipulation der UI-Elemente an.
- *Technologieneutralität (Swing/JavaFX)*: Da der Presenter ausschließlich über das Interface `ChatView` kommuniziert, ist der Dialogkern vollständig von der Framework-Implementierung entkoppelt. Dies ermöglicht es, die grafische Oberfläche wahlweise mit *JavaFX* oder *Swing* umzusetzen (oder zwischen diesen zu wechseln), ohne eine einzige Zeile Code im Presenter oder im Model ändern zu müssen. 
- *Testbarkeit*: Durch die Entkopplung kann die gesamte Dialoglogik in Unit-Tests geprüft werden, indem die View durch ein Mock-Objekt ersetzt wird. Dadurch sind automatisierte Tests ohne eine aktive grafische Oberfläche möglich.

= Einblick in den Interaktionsablauf beim Versand einer Chat-Nachricht

Um ein besseres Verständnis für die Funktionsweise der bereits beschriebenen Architektur zu erhalten, wurde das Versenden einer Nachricht von einem Client an einen weiteren Client modelliert.

 Im Folgenden wird der Ablauf als Sequenzdiagramm wiedergegeben.  Zur Vorbereitung des Programmablaufs muss ein Server aufgesetzt sein sowie zwei Clients, welche zudem bei dem Server registriert sind. 

 #image("/assets/Sequenzdiagramm_Client_A.png", width: 100%)

Client A, Absender der Nachricht, befindet sich auf der Chatoberfläche. Dabei befindet sich dieser in der Klasse `ChatWindow`, von welcher er Nachrichten an den Empfänger Client E abschicken kann. Bei betätigen der Enter-Taste im Chat-Feld wird die Methode `onMessageTextAreaEnter()` ausgeführt. Diese Methode führt wiederum die Methode `call()` aus, welche den Inhalt des Textfeldes an die Klasse `ChatPresenter` übermittelt. `ChatPresenter` ruft ihre private Methode `sendChatMessage()` auf. Diese Methode erzeug ein `ChatMessage`-Objekt mit dem Inhalt der Nachricht und der Empfänger-ID und postet dieses anschließend als `SendChatMessageEvent`. Der `SocketClient` des Clients A, der mit seiner Methode `onSendChatMessage()` auf dieses Event reagiert, führt seine Methode `sendRequest()` auf. Dabei übergibt der Socket das `ChatMessage`-Objekt sowie einen Request-Code mit dem Hinweis ChatMessage an den Server.

#image("/assets/Sequenzdiagramm_Server.png", width: 100%)

Der Server hat bereits bei der Registrierung eines Clients einen eigenen Thread für diesen Client, welcher durch die Klasse `SocketWorker` repräsentiert wird, erstellt.
 Dort wird durch den `SocketWorker` die Request angenommen, da dieser mit der Methode `waitForRequests()` auf Anfragen des Clients wartet. Hier erzeugt er ein `RequestReservedEvent`-Objekt, welches gepostet wird. Der `RequestRouter` reagiert mit seiner Methode `onRequestReserved()` auf dieses Event. Er erzeugt mit Hilfe der Klasse `RequestHandlerFactory` ein neues `RequestHandler`-Objekt in Abhängigkeit des Hinweises, welcher durch den Client A mit übermittelt wurde. Anschließend ruft der `RequestRouter` den erzeugten  Handler mit der Methode `handle()` auf und übergibt das Event, welches er selbst erhalten hat.
In diesem Fall reagiert die Klasse `ChatMessageRequestHandler`, die durch die Factory-Klasse erzeugt wurde. Der Server erzeugt in dieser Klasse ein neues `ChatMessage`-Objekt, welches die Nachricht von Client A enthält sowie die ID des Senders. Anschließend wird
ein `ForwardChatMessageEvent`-Objekt erzeugt, dem das `ChatMessage`-Objekt und die Empfänger-ID übergeben wird und postet es. Dadurch landen die Daten wieder bei dem `SocketWorker` des Servers. Dieser horcht mit der Methode `onForwardChatMessage()` auf das Event und verarbeitet die Daten um anschließend die private Methode `sendChatMessage()`auszuführen. In dieser Methode wird ein neues `Response`-Objekt erzeugt, welches an den Client E mit Hilfe der Methode `response()` geschickt wird.

 #image("/assets/Sequenzdiagramm_Client_E.png", width: 110%)

 So wie der `SocketWorker` des Servers dauerhaft auf Anfragen eines Clients wartet, so wartet auch der `SocketClient`des Clients E mit der Methode `waitForIncomingMessages()` auf Antworten des Servers. Sobald eine Antwort eintrifft, wird die private Methode `handleResponse()` ausgeführt. In dieser Methode wird ähnlich wie auf der Serverseite mit der Klasse `ResponseHandlerFactory` ein neues `ResponseHandler`-Objekt erzeugt, welches mit der Methode `handle()` auf die Antwort des Servers reagiert. In diesem Fall ist es die Klasse `ChatMessageResponseHandler`, welche die Antwort verarbeitet. In dessen `handle`-Methode wird die Antwort des Servers wieder in ein `ChatMessage`-Objekt umgewandelt, um es anschließend mit dem Aufruf der Methode `processReceivedChatMessage()` an das Interface `ChattingManager` zu übergeben. Die Klasse `ChattingManagerImpl` implementiert dieses Interface und verarbeitet die Nachricht in seiner Methode `processReceivedChatMessage()`, um sie schließlich als `ChatMessageReceivedEvent` zu posten. Der `ChatPresenter` des Clients E reagiert mit seiner Methode `onChatMessageReceived()` auf dieses Event und aktualisiert die Chatoberfläche, um die neue Nachricht anzuzeigen.



= Fazit

Die Architekturanalyse des "chat-socket"-Systems verdeutlicht eine konsequente Trennung von Belangen (Separation of Concerns), die für ein Projekt dieser Größenordnung bemerkenswert strukturiert umgesetzt wurde. Durch die Anwendung des Model-View-Presenter (MVP)-Musters in Kombination mit dem Factory-Design-Pattern ist es den Entwicklern gelungen, eine hohe Austauschbarkeit der UI-Komponenten zu gewährleisten. Die Tatsache, dass das System nahtlos zwischen Swing und JavaFX wechseln kann, ohne die zugrunde liegende Programmlogik zu tangieren, unterstreicht die Flexibilität der Architektur.

Ein wesentlicher Erfolgsfaktor für die Wartbarkeit des Systems ist der Einsatz eines ereignisbasierten Kommunikationsmodells über den Guava EventBus. Diese lose Kopplung minimiert direkte Abhängigkeiten zwischen den Komponenten und erleichtert die Erweiterbarkeit um neue Funktionen, da neue Listener (z. B. für zusätzliche Chat-Features) ohne tiefgreifende Änderungen am bestehenden Code integriert werden können.
