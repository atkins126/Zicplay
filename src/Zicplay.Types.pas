unit Zicplay.Types;

interface

uses
  System.Generics.Collections,
  System.Classes,
  System.JSON;

type
  TPlaylist = class;
  IConnector = interface;

  /// <summary>
  /// A function getting the UniqID of a song to answer with it's local file name and path (realy local or in a cache)
  /// Used as event.
  /// </summary>
  TSongFileNameEvent = function(AUniqID: string): string of object;

  /// <summary>
  /// Song infos (from MP3 metadata or others)
  /// </summary>
  TSong = class
  private
    FFilename: string;
    FPlaylist: TPlaylist;
    FOrder: integer;
    FTitle: string;
    FTitleLowerCase: string;
    FArtist: string;
    FArtistLowerCase: string;
    FCategory: string;
    FCategoryLowerCase: string;
    FAlbum: string;
    FAlbumLowerCase: string;
    FPublishedDate: TDate;
    FUniqID: string;
    FonGetFilename: TSongFileNameEvent;
    FDuration: integer;
    procedure SetAlbum(const Value: string);
    procedure SetArtist(const Value: string);
    procedure SetCategory(const Value: string);
    procedure SetFilename(const Value: string);
    procedure SetOrder(const Value: integer);
    procedure SetPublishedDate(const Value: TDate);
    procedure SetPlaylist(const Value: TPlaylist);
    procedure SetTitle(const Value: string);
    function GetPublishedYear: word;
    procedure SetonGetFilename(const Value: TSongFileNameEvent);
    procedure SetUniqID(const Value: string);
    function GetFileName: string;
    procedure SetDuration(const Value: integer);
    function GetDurationAsTime: string;
  protected
  public
    /// <summary>
    /// Song title
    /// </summary>
    property Title: string read FTitle write SetTitle;
    property TitleLowerCase: string read FTitleLowerCase;
    /// <summary>
    /// Artist (or artists) : singer, musician, ...
    /// </summary>
    property Artist: string read FArtist write SetArtist;
    property ArtistLowerCase: string read FArtistLowerCase;
    /// <summary>
    /// Name of the album or single
    /// </summary>
    property Album: string read FAlbum write SetAlbum;
    property AlbumLowerCase: string read FAlbumLowerCase;
    /// <summary>
    /// Duration of this song in seconds
    /// </summary>
    property Duration: integer read FDuration write SetDuration;
    /// <summary>
    /// Return the duration in HH:MM:SS string format
    /// </summary>
    property DurationAsTime: string read GetDurationAsTime;
    /// <summary>
    /// Publication date (at least the year if known)
    /// </summary>
    property PublishedDate: TDate read FPublishedDate write SetPublishedDate;
    /// <summary>
    /// Publication year (extracted from PublishedDate)
    /// </summary>
    property PublishedYear: word read GetPublishedYear;
    /// <summary>
    /// Category of the song (dance, techno, classic, ...)
    /// </summary>
    property Category: string read FCategory write SetCategory;
    property CategoryLowerCase: string read FCategoryLowerCase;
    /// <summary>
    /// Order of the song in it's album
    /// </summary>
    property Order: integer read FOrder write SetOrder;
    /// <summary>
    /// Unique ID of the song for its playlist
    /// </summary>
    property UniqID: string read FUniqID write SetUniqID;
    /// <summary>
    /// Playlist source for this song
    /// </summary>
    property Playlist: TPlaylist read FPlaylist write SetPlaylist;
    /// <summary>
    /// Return the file name and local path of this song to open it in the TMediaPlayer component
    /// </summary>
    property FileName: string read GetFileName write SetFilename;
    /// <summary>
    /// Called each time property FileName is read if the FFileName field is empty.
    /// Use it for your connectors if the song has no local file (to access to a local cache).
    /// </summary>
    property onGetFilename: TSongFileNameEvent read FonGetFilename
      write SetonGetFilename;

    /// <summary>
    /// Load song datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save song datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end;

  /// <summary>
  /// Playlist (list of songs from a connector)
  /// </summary>
  TPlaylist = class(TList<TSong>)
  private
    FConnector: IConnector;
    procedure SetConnector(const Value: IConnector);
  protected
  public
    /// <summary>
    /// Connector for this playlist
    /// </summary>
    property Connector: IConnector read FConnector write SetConnector;

    /// <summary>
    /// Sort the songs in this list by Album / Order / Title
    /// </summary>
    procedure SortByAlbum;
    /// <summary>
    /// Sort the songs in this list by Artist / Album / Order / Title
    /// </summary>
    procedure SortByArtist;
    /// <summary>
    /// Sort the songs in this list by Title / Album
    /// </summary>
    procedure SortByTitle;
    /// <summary>
    /// Sort the songs in this list by Category / Album / Order / Title
    /// </summary>
    procedure SortByCategoryAlbum;
    /// <summary>
    /// Sort the songs in this list by Category / Title / Album
    /// </summary>
    procedure SortByCategoryTitle;

    /// <summary>
    /// Load song list datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save song list datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end; // TODO : add a ClearAndFreeItems() method

  /// <summary>
  /// Used as callback procedure between a connector and a playlist
  /// </summary>
  TZicPlayGetPlaylistProc = reference to procedure(APlaylist: TPlaylist);

  /// <summary>
  /// Interface for Zicplay connectors (see it like a driver)
  /// </summary>
  IConnector = interface
    ['{2A668080-A4BC-4E5B-8640-4EA0809E21DA}']
    /// <summary>
    /// Name of this connector (displayed to the users)
    /// </summary>
    function getName: string;

    /// <summary>
    /// Uniq ID (a GUID is fine) for this connector
    /// </summary>
    function getUniqID: string;

    /// <summary>
    /// Display setup dialog for a playlist using this connector
    /// </summary>
    procedure PlaylistSetupDialog(Params: TJSONObject);

    /// <summary>
    /// True if the PlaylistSetupDialog procedure can be called to display a dialog box from the playlist options
    /// False if no setup dialog for this connector
    /// </summary>
    function hasPlaylistSetupDialog: boolean;

    /// <summary>
    /// Display setup dialog for a connector
    /// </summary>
    procedure SetupDialog;

    /// <summary>
    /// True if the SetupDialog procedure can be called to display a dialog box from the Tools menu
    /// False if no setup dialog for this connector
    /// </summary>
    function hasSetupDialog: boolean;

    /// <summary>
    /// Return the playlist from a connector (with playlist parameters)
    /// </summary>
    procedure GetPlaylist(Params: TJSONObject;
      CallbackProc: TZicPlayGetPlaylistProc);

    /// <summary>
    /// Load connector parameters from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);

    /// <summary>
    /// Save connector parameters in a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end;

  /// <summary>
  /// List of registered connectors
  /// (it's a singleton, use TConnectorsList.Current to access to it's instance)
  /// </summary>
  TConnectorsList = class
  private
    List: TList<IConnector>;
    class var FCurrent: TConnectorsList;
    constructor Create;
    destructor Destroy; override;
  protected
  public
    /// <summary>
    /// Return the singleton instance of this class
    /// </summary>
    class function Current: TConnectorsList;
    /// <summary>
    /// Used to register the connectors
    /// </summary>
    procedure Register(AConnector: IConnector);
    /// <summary>
    /// Sort the items in the list by alphabetical order of their name.
    /// </summary>
    procedure Sort;
    /// <summary>
    /// Return the number of registered connectors
    /// </summary>
    function Count: integer;
    /// <summary>
    /// Return the registered connector at specified index (if available)
    /// </summary>
    function GetConnectorAt(AIndex: integer): IConnector;
    /// <summary>
    /// Return the registered connector from it's UniqID (if available)
    /// </summary>
    function GetConnectorFromUID(AUniqID: string): IConnector;
  end;

  /// <summary>
  /// Base connector if you want an ancestor for your connectors instead of
  /// using the interface IConnector.
  /// </summary>
  TConnector = class(TInterfacedObject, IConnector)
  public
    /// <summary>
    /// Name of this connector (displayed to the users)
    /// </summary>
    function getName: string; virtual; abstract;

    /// <summary>
    /// Uniq ID (a GUID is fine) for this connector
    /// </summary>
    function getUniqID: string; virtual; abstract;

    /// <summary>
    /// Display setup dialog for a playlist using this connector
    /// </summary>
    procedure PlaylistSetupDialog(Params: TJSONObject); virtual; abstract;

    /// <summary>
    /// True if the PlaylistSetupDialog procedure can be called to display a dialog box from the playlist options
    /// False if no setup dialog for this connector
    /// </summary>
    function hasPlaylistSetupDialog: boolean; virtual;

    /// <summary>
    /// Display setup dialog for a connector
    /// </summary>
    procedure SetupDialog; virtual;

    /// <summary>
    /// True if the SetupDialog procedure can be called to display a dialog box from the Tools menu
    /// False if no setup dialog for this connector
    /// </summary>
    function hasSetupDialog: boolean; virtual;

    /// <summary>
    /// Return the playlist from a connector (with playlist parameters)
    /// </summary>
    procedure GetPlaylist(Params: TJSONObject;
      CallbackProc: TZicPlayGetPlaylistProc); virtual; abstract;

    /// <summary>
    /// Load connector parameters from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream); virtual;

    /// <summary>
    /// Save connector parameters in a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream); virtual;
  end;

implementation

uses
  fmx.DialogService,
  System.DateUtils,
  System.SysUtils,
  System.Generics.Defaults;

{ TSong }

function TSong.GetDurationAsTime: string;
begin
  // TODO : � compl�ter
  result := 'n/a';
end;

function TSong.GetFileName: string;
begin
  if (not FFilename.isempty) then
    result := FFilename
  else if assigned(onGetFilename) then
    result := onGetFilename(FUniqID)
  else
    result := '';
end;

function TSong.GetPublishedYear: word;
begin
  result := yearof(PublishedDate);
  // TODO : replace by TDate.getYear when a helpers will be available
end;

procedure TSong.LoadFromStream(AStream: TStream);
begin
  // TODO : � compl�ter
{$MESSAGE warn 'todo'}
end;

procedure TSong.SaveToStream(AStream: TStream);
begin
  // TODO : � compl�ter
{$MESSAGE warn 'todo'}
end;

procedure TSong.SetAlbum(const Value: string);
begin
  FAlbum := Value;
  FAlbumLowerCase := FAlbum.ToLower;
end;

procedure TSong.SetArtist(const Value: string);
begin
  FArtist := Value;
  FArtistLowerCase := FArtist.ToLower;
end;

procedure TSong.SetCategory(const Value: string);
begin
  FCategory := Value;
  FCategoryLowerCase := FCategory.ToLower;
end;

procedure TSong.SetDuration(const Value: integer);
begin
  FDuration := Value;
end;

procedure TSong.SetFilename(const Value: string);
begin
  FFilename := Value;
end;

procedure TSong.SetonGetFilename(const Value: TSongFileNameEvent);
begin
  FonGetFilename := Value;
end;

procedure TSong.SetOrder(const Value: integer);
begin
  FOrder := Value;
end;

procedure TSong.SetPublishedDate(const Value: TDate);
begin
  FPublishedDate := Value;
end;

procedure TSong.SetPlaylist(const Value: TPlaylist);
begin
  FPlaylist := Value;
end;

procedure TSong.SetTitle(const Value: string);
begin
  FTitle := Value;
  FTitleLowerCase := FTitle.ToLower;
end;

procedure TSong.SetUniqID(const Value: string);
begin
  FUniqID := Value;
end;

{ TPlaylist }

procedure TPlaylist.LoadFromStream(AStream: TStream);
begin
  // TODO : � compl�ter
{$MESSAGE warn 'todo'}
end;

procedure TPlaylist.SaveToStream(AStream: TStream);
begin
  // TODO : � compl�ter
{$MESSAGE warn 'todo'}
end;

procedure TPlaylist.SetConnector(const Value: IConnector);
begin
  FConnector := Value;
end;

procedure TPlaylist.SortByAlbum;
begin
  Sort(TComparer<TSong>.Construct(
    function(const A, B: TSong): integer
    begin
      if (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase = B.FTitleLowerCase) then
        result := 0
      else if (A.FAlbumLowerCase < B.FAlbumLowerCase) or
        ((A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
        ((A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase < B.FTitleLowerCase)) then
        result := -1
      else
        result := 1;
    end));
end;

procedure TPlaylist.SortByArtist;
begin
  Sort(TComparer<TSong>.Construct(
    function(const A, B: TSong): integer
    begin
      if (A.FArtistLowerCase = B.FArtistLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase = B.FTitleLowerCase) then
        result := 0
      else if (A.FArtistLowerCase < B.FArtistLowerCase) or
        ((A.FArtistLowerCase = B.FArtistLowerCase) and
        (A.FAlbumLowerCase < B.FAlbumLowerCase)) or
        ((A.FArtistLowerCase = B.FArtistLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
        ((A.FArtistLowerCase = B.FArtistLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase < B.FTitleLowerCase)) then
        result := -1
      else
        result := 1;
    end));
end;

procedure TPlaylist.SortByCategoryAlbum;
begin
  Sort(TComparer<TSong>.Construct(
    function(const A, B: TSong): integer
    begin
      if (A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase = B.FTitleLowerCase) then
        result := 0
      else if (A.FCategoryLowerCase < B.FCategoryLowerCase) or
        ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FAlbumLowerCase < B.FAlbumLowerCase)) or
        ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
        ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
        (A.FTitleLowerCase < B.FTitleLowerCase)) then
        result := -1
      else
        result := 1;
    end));
end;

procedure TPlaylist.SortByCategoryTitle;
begin
  Sort(TComparer<TSong>.Construct(
    function(const A, B: TSong): integer
    begin
      if (A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FTitleLowerCase = B.FTitleLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) then
        result := 0
      else if (A.FCategoryLowerCase < B.FCategoryLowerCase) or
        ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FTitleLowerCase < B.FTitleLowerCase)) or
        ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
        (A.FTitleLowerCase = B.FTitleLowerCase) and
        (A.FAlbumLowerCase < B.FAlbumLowerCase)) then
        result := -1
      else
        result := 1;
    end));
end;

procedure TPlaylist.SortByTitle;
begin
  Sort(TComparer<TSong>.Construct(
    function(const A, B: TSong): integer
    begin
      if (A.FTitleLowerCase = B.FTitleLowerCase) and
        (A.FAlbumLowerCase = B.FAlbumLowerCase) then
        result := 0
      else if (A.FTitleLowerCase < B.FTitleLowerCase) or
        ((A.FTitleLowerCase = B.FTitleLowerCase) and
        (A.FAlbumLowerCase < B.FAlbumLowerCase)) then
        result := -1
      else
        result := 1;
    end));
end;

{ TConnectorsList }

function TConnectorsList.Count: integer;
begin
  result := List.Count;
end;

constructor TConnectorsList.Create;
begin
  List := TList<IConnector>.Create;
end;

class function TConnectorsList.Current: TConnectorsList;
begin
  if not assigned(FCurrent) then
    FCurrent := TConnectorsList.Create;

  if assigned(FCurrent) then
    result := FCurrent
  else
    result := nil;
end;

destructor TConnectorsList.Destroy;
begin
  FCurrent := nil;
  List.Free;
  inherited;
end;

procedure TConnectorsList.Register(AConnector: IConnector);
var
  i: integer;
  ItemFound: boolean;
begin
  ItemFound := false;
  for i := 0 to List.Count - 1 do
    if List[i].getUniqID = AConnector.getUniqID then
    begin
      ItemFound := true;
      break;
    end;
  if not ItemFound then
    List.Add(AConnector);
end;

procedure TConnectorsList.Sort;
begin
  List.Sort(TComparer<IConnector>.Construct(
    function(const A, B: IConnector): integer
    begin
      if A.getName = B.getName then
        result := 0
      else if A.getName < B.getName then
        result := -1
      else
        result := 1;
    end));
end;

function TConnectorsList.GetConnectorAt(AIndex: integer): IConnector;
begin
  if (AIndex >= 0) and (AIndex < List.Count) then
    result := List.Items[AIndex]
  else
    result := nil;
end;

function TConnectorsList.GetConnectorFromUID(AUniqID: string): IConnector;
var
  i: integer;
begin
  result := nil;
  for i := 0 to List.Count - 1 do
    if (List.Items[i].getUniqID = AUniqID) then
    begin
      result := List.Items[i];
      break;
    end;
end;

{ TConnector }

function TConnector.hasPlaylistSetupDialog: boolean;
begin
  result := false;
end;

function TConnector.hasSetupDialog: boolean;
begin
  result := true;
end;

procedure TConnector.LoadFromStream(AStream: TStream);
begin
  // does nothing by default (no parameter to load for this object)
end;

procedure TConnector.SaveToStream(AStream: TStream);
begin
  // does nothing by default (no parameter to save for this object)
end;

procedure TConnector.SetupDialog;
begin
  tdialogservice.ShowMessage(getName);
end;

initialization

finalization

TConnectorsList.Current.Free;

end.
