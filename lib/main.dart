import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // printGraph();
    mazeEmoji = staticEmojiMazeGenerator();
    super.initState();
  }

  int emojiRow = 0;
  int emojiColumn = 0;

  int generateRandomNumber(int min, int max) {
    Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  List<List<int>> gr = List.generate(144, (_) => []);
  List<bool> visited = List<bool>.filled(144, false);
  List<List<bool>> vis = List.generate(12, (_) => List.filled(12, false));
  List<int> path = [];
  List<List<String>> mazeEmoji = List.generate(12, (_) => List.filled(12, ''));
  List<Pair<int, int>> directions = [
    Pair(0, 1),
    Pair(1, 0),
    Pair(0, -1),
    Pair(-1, 0)
  ];
  int n = 10, m = 10;

  bool isValid(int i, int j) {
    return i >= 0 && j >= 0 && i < n && j < m;
  }

  List<Pair<int, int>> getRandomNeighbors(int x, int y, int x1, int y1) {
    List<Pair<int, int>> neighbors = [];
    for (var dir in directions) {
      int newX = x + dir.first;
      int newY = y + dir.second;

      if (isValid(newX, newY) && Pair(newX, newY) != Pair(x1, y1)) {
        neighbors.add(Pair(newX, newY));
      }
    }
    for (int i = 1; i <= generateRandomNumber(1, 10); i++) {
      neighbors.shuffle();
    }
    return neighbors;
  }

  List<List<int>> staticMazeGenerator() {
    List<List<int>> maze = List.generate(n, (_) => List.filled(m, -1));
    int ct = 1;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        maze[i][j] = ct++;
      }
    }
    return maze;
  }

  List<List<String>> staticEmojiMazeGenerator() {
    List<List<String>> maze = List.generate(n, (_) => List.filled(m, ''));
    // int ct = 1;
    String peaches = '🍑';
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        int randomNumber = generateRandomNumber(1, 10);
        if (randomNumber % 2 == 0) {
          maze[i][j] = peaches;
        }
      }
    }
    return maze;
  }

  void randomisedDfs(List<List<int>> maze, int x, int y, int x1, int y1) {
    List<Pair<int, int>> neighbors = getRandomNeighbors(x, y, x1, y1);
    vis[x][y] = true;

    for (var child in neighbors) {
      if (!vis[child.first][child.second]) {
        gr[maze[x][y]].add(maze[child.first][child.second]);
        gr[maze[child.first][child.second]].add(maze[x][y]);
        randomisedDfs(maze, child.first, child.second, x, y);
      }
    }
  }

  List<int> findPath(int start, int dest) {
    List<int> path = [];
    path.add(start);
    visited[start] = true;

    if (start == dest) {
      return path;
    }

    for (int neighbor in gr[start]) {
      if (!visited[neighbor]) {
        List<int> subPath = findPath(neighbor, dest);
        if (subPath.isNotEmpty) {
          path.addAll(subPath);
          return path;
        }
      }
    }
    path.removeLast();
    return path;
  }

  void highlightPath() {
    setState(() {
      if (path.isEmpty) {
        // print("Yes");
        path = findPath(1, 100);
        // print(path);
      } else {
        // print("NO");
        visited = List<bool>.filled(144, false);
        path = [];
      }
    });
  }

  Border determineBorder(int row, int column, int cell) {
    bool topBorder = row == 0 || !gr[cell].contains(cell - m);
    bool leftBorder = column == 0 || !gr[cell].contains(cell - 1);
    bool bottomBorder = row == n - 1 || !gr[cell].contains(cell + m);
    bool rightBorder = column == m - 1 || !gr[cell].contains(cell + 1);

    return Border(
      top: topBorder ? const BorderSide(color: Colors.grey) : BorderSide.none,
      left: leftBorder ? const BorderSide(color: Colors.grey) : BorderSide.none,
      bottom:
          bottomBorder ? const BorderSide(color: Colors.grey) : BorderSide.none,
      right:
          rightBorder ? const BorderSide(color: Colors.grey) : BorderSide.none,
    );
  }

  void printGraph() {
    for (int i = 1; i <= 100; i++) {
      print("i---> $i ---> ${gr[i]}");
    }
  }

  void clearGraph() {
    for (int i = 0; i < 144; i++) {
      gr[i] = [];
      visited[i] = false;
    }
    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 12; j++) {
        vis[i][j] = false;
      }
    }
  }

  void moveEmoji(int rowDelta, int columnDelta) {
    setState(() {
      int newRow = emojiRow + rowDelta;
      int newColumn = emojiColumn + columnDelta;
      // print("$emojiRow $emojiColumn $newRow $newColumn");
      int currentCell = emojiRow * 10 + emojiColumn + 1;
      int newCell = newRow * 10 + newColumn + 1;
      // print("$currentCell $newCell");
      bool flag = false;
      for (int child in gr[currentCell]) {
        flag |= (child == newCell);
      }
      if (newRow >= 0 &&
          newRow < 10 &&
          newColumn >= 0 &&
          newColumn < 10 &&
          flag) {
        mazeEmoji[emojiRow][emojiColumn] = '';
        emojiRow = newRow;
        emojiColumn = newColumn;
      }
      // print("$rowDelta $columnDelta $flag");
    });
  }

  @override
  Widget build(BuildContext context) {
    List<List<int>> maze = staticMazeGenerator(); // Generate maze
    // List<List<String>> mazeEmoji = staticEmojiMazeGenerator();
    randomisedDfs(maze, 0, 0, -1, -1);
    // printGraph();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji Maze Game'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: highlightPath,
            icon: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    emojiRow = 0;
                    emojiColumn = 0;
                    maze = staticMazeGenerator();
                    mazeEmoji = staticEmojiMazeGenerator();
                    clearGraph();
                    randomisedDfs(maze, 0, 0, -1, -1);
                    path = [];
                    // mazeEmoji = List.generate(12, (_) => List.filled(12, '🍑'));
                  });
                },
                child: const Text("Generate New Maze")),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 50, left: (MediaQuery.of(context).size.width - 400) / 2),
              child: SizedBox(
                height: 400,
                width: 400,
                child: Stack(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                      ),
                      itemCount: 100,
                      itemBuilder: (BuildContext context, int index) {
                        int row = index ~/ 10;
                        int column = index % 10;
                        int cell = maze[row][column];
                        if (path.contains(cell)) {
                          if (row == emojiRow && column == emojiColumn) {
                            // Return an AnimatedContainer with a border for the cell containing the emoji
                            return AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 300), // Animation duration
                              decoration: BoxDecoration(
                                border: determineBorder(row, column, cell),
                                color: Colors.lightGreen.withOpacity(
                                    0.5), // Customize border properties as needed
                              ),
                              child: const Center(
                                child: Text(
                                  '', // Display emoji here
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          } else {
                            // Return a container without a border for other cells
                            return Container(
                              decoration: BoxDecoration(
                                border: determineBorder(row, column,
                                    cell), // Customize border properties as needed
                                color: Colors.lightGreen.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Text(
                                  mazeEmoji[row][
                                      column], //--------------------------------------------------------------------->
                                  // '🍑',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          }
                          // // Highlight the path cells with light green background
                          // return Container(
                          //   color: Colors.lightGreen.withOpacity(0.5),
                          //   child: Center(
                          //     child: Text(
                          //       '🍑', // Example emoji
                          //       style: const TextStyle(fontSize: 16),
                          //     ),
                          //   ),
                          // );
                        } else {
                          if (row == emojiRow && column == emojiColumn) {
                            // Return an AnimatedContainer with a border for the cell containing the emoji
                            return AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 300), // Animation duration
                              decoration: BoxDecoration(
                                border: determineBorder(row, column,
                                    cell), // Customize border properties as needed
                              ),
                              child: const Center(
                                child: Text(
                                  '', // Display emoji here
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          } else {
                            // Return a container without a border for other cells
                            return Container(
                              decoration: BoxDecoration(
                                border: determineBorder(row, column,
                                    cell), // Customize border properties as needed
                                // color: Colors.lightGreen.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Text(
                                  mazeEmoji[row][column],
                                  // '🍑',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          }
                          // // Normal cells
                          // return Container(
                          //   decoration: BoxDecoration(
                          //     border: Border.all(color: Colors.grey),
                          //   ),
                          //   child: Center(
                          //     child: Text(
                          //       '🍑', // Example emoji
                          //       style: const TextStyle(fontSize: 16),
                          //     ),
                          //   ),
                          // );
                        }
                      },
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 400), // Animation duration
                      top: emojiRow * 40 + 7, // Multiply by cell height (40px)
                      left:
                          emojiColumn * 40 + 7, // Multiply by cell width (40px)
                      child: const Text('😃', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.amber,
                      ),
                      child: IconButton(
                        onPressed: () => moveEmoji(-1, 0),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 4,
                      right: 4,
                      bottom: 100,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.amber,
                      ),
                      child: IconButton(
                        onPressed: () => moveEmoji(0, -1),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 4,
                      right: 4,
                      bottom: 100,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.amber,
                      ),
                      child: IconButton(
                        onPressed: () => moveEmoji(1, 0),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 4,
                      right: 4,
                      bottom: 100,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.amber,
                      ),
                      child: IconButton(
                        onPressed: () => moveEmoji(0, 1),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return '($first, $second)';
  }
}
