int DIFFICULTY = 5;
int MAX_STARS = 80;
int GAME_WIDTH = 800;
int GAME_HEIGHT = 450;
int SCREEN_WIDTH = 800;
int SCREEN_HEIGHT = GAME_HEIGHT;

Star stars[] = new Star[MAX_STARS];
Player player = new Player();
ArrayList asteroids = new ArrayList();

void setup() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  smooth();

  for (i = 0; i < MAX_STARS; i++) {
    stars[i] = new Star();
  }
}

void draw() {
  background(0);
  
  // Draw stars
  for (i = 0; i < MAX_STARS; i++) {
    stars[i].update();
  }

  // Draw player
  player.update();

  if (frameCount % ceil(150 / DIFFICULTY) == 0) {
    asteroids.add(new Asteroid());
  }

  for (int i = asteroids.size() - 1; i >= 0; i--) {
    Asteroid asteroid = (Asteroid) asteroids.get(i);
    asteroid.update();
    if (asteroid.isFinished()) {
      asteroids.remove(i);
    }
  }
}

void keyPressed() {
  switch (keyCode) {
    // Left arrow
    case 37:
      player.beginMovingLeft();
      break;

    // Right arrow
    case 39:
      player.beginMovingRight();
      break;

    // Spacebar
    case 32:
      player.beginShooting(frameCount);
  }
}

void keyReleased() {
  switch (keyCode) {
    // Left arrow
    case 37:
      player.stopMovingLeft();
      break;

    // Right arrow
    case 39:
      player.stopMovingRight();
      break;

    // Spacebar
    case 32:
      player.stopShooting();
  }
}

void newGame() {
  player = new Player();
  asteroids = new ArrayList();
}

class Player {
  float position_x = GAME_WIDTH / 2; // relative to game
  float position_y = GAME_HEIGHT * (9/10); // relative to game
  float speed_x = GAME_WIDTH * 0.005; // how fast to move when going left/right
  float speed_y = GAME_HEIGHT * 0.003; // how fast to move when going forward (auto)
  float shipSize = GAME_WIDTH / 50;
  int score = 0;

  int health = 3; // hit points
  bool isHit = false;
  ArrayList shots;
  int frameShootStart;

  bool shooting = false;
  bool movingLeft = false;
  bool movingRight = false;

  Player() {
    shots = new ArrayList();
  }

  float getSpeedX() {
    return speed_x;
  }

  float getSpeedY() {
    return speed_y;
  }

  float getPositionX() {
    return x;
  }

  float getPositionY() {
    return y;
  }

  void addScore(int points) {
    score += points;
  }

  void shoot() {
    shots.add(new Shot(position_x, position_y));
  }

  void beginShooting(int f) {
    if (shooting) return;
    shooting = true;
    frameShootStart = f;
    shoot(); // shoot immediately
  }

  void stopShooting() {
    shooting = false;
  }

  void beginMovingLeft() {
    movingLeft = true;
  }

  void beginMovingRight() {
    movingRight = true;
  }

  bool isMovingLeft() {
    return (movingLeft && !movingRight && position_x > 0);
  }

  void stopMovingLeft() {
    movingLeft = false;
  }

  void stopMovingRight() {
    movingRight = false;
  }

  bool isMovingRight() {
    return (!movingLeft && movingRight && position_x < GAME_WIDTH);
  }

  void gameOver() {
    alert("Game over! Your score: " + score);
    newGame();
  }

  void update() {
    if (isMovingLeft()) {
      position_x -= speed_x;
    } else if (isMovingRight()) {
      position_x += speed_x;
    }

    if (shooting && (frameCount - frameShootStart) % 8 == 0) {
      shoot();
    }

    for (int i = shots.size() - 1; i >= 0; i--) {
      Shot shot = (Shot) shots.get(i);
      shot.update();
      if (shot.isFinished()) {
        shots.remove(i);
      }
    }

    x1 = position_x;
    y1 = position_y;
    x2 = position_x + (shipSize / 2);
    y2 = position_y + shipSize;
    x3 = position_x - (shipSize / 2);
    y3 = position_y + shipSize;

    for (int i = asteroids.size() - 1; i >= 0; i--) {
      Asteroid asteroid = (Asteroid) asteroids.get(i);
      
      if (asteroid.collidesWith(x1, y1)) {
        isHit = true;
        health -= 1;
        asteroids.remove(i);
        if (health < 0) {
          return gameOver();
        }
      }
    }

    // Ship
    if (isHit) {
      stroke(255);
      fill(200);
      fill(255, 0, 0);
      isHit = false;
    } else {
      stroke(140);
      fill(200, 210, 220);
    }
    triangle(x1, y1, x2, y2, x3, y3);

    // Window
    noStroke();
    fill(0);
    triangle(
      position_x, position_y + (shipSize * 0.25), 
      position_x + (shipSize * 0.15), position_y + (shipSize * 0.65), 
      position_x - (shipSize * 0.15), position_y + (shipSize * 0.65)
    );

    // Draw health
    for (int i = 0; i < health; i++) {
      x1 = GAME_WIDTH - (i * 25) - 30;
      x2 = x1 + (shipSize / 2);
      x3 = x1 - (shipSize / 2);
      y1 = 20;
      y2 = y1 + shipSize;
      y3 = y1 + shipSize;

      stroke(140, 200);
      fill(200, 210, 220, 200);
      triangle(x1, y1, x2, y2, x3, y3);
    }
  }
};

class Shot {
  float position_x;
  float position_y;
  float strength = 1;
  float speed = GAME_HEIGHT * 0.03;
  float WIDTH = GAME_HEIGHT * 0.01;
  float HEIGHT = WIDTH * 4;
  bool finished = false;

  Shot (float px, float py) {
    position_x = px;
    position_y = py;
  }

  void update() {
    position_y -= speed;

    if (position_y < 0) {
      finished = true;
      return;
    }

    // Detect collision with asteroids
    for (int i = asteroids.size() - 1; i >= 0; i--) {
      Asteroid asteroid = (Asteroid) asteroids.get(i);
      
      if (asteroid.collidesWith(position_x, position_y)) {
        asteroid.hit(strength);
        finished = true;
      }
    }

    float size = 4.0;
    stroke(180, 180, 0, 0.5);
    fill(255, 220, 50);

    // draw two
    rect(position_x - WIDTH / 2 - 5, position_y - HEIGHT / 2, WIDTH, HEIGHT, WIDTH);
    rect(position_x - WIDTH / 2 + 5, position_y - HEIGHT / 2, WIDTH, HEIGHT, WIDTH);
  }

  bool isFinished() {
    return finished;
  }
};

class Star {
  float x;
  float y;
  float size;
  float speed = 0.4;
  int color[] = new int(3);

  Star () {
    reset();
    y = random(0, GAME_HEIGHT);
    x = random(0, GAME_WIDTH);
  }

  void reset() {
    x = 0;
    y = 0;
    size = sq(random(0.5, 2.2));
    color[0] = random(100, 200);
    color[1] = color[0] * 1.2;
    color[2] = 255;
  }

  void update() {
    y += player.getSpeedY() * speed * size;

    if (player.isMovingLeft()) {
      x += player.getSpeedY() * speed * size * 0.5;
    } else if (player.isMovingRight()) {
      x -= player.getSpeedY() * speed * size * 0.5;
    }

    if ((y + size) > GAME_HEIGHT) {
      reset();
      x = random(0, GAME_WIDTH);
    }

    // stroke(color[0], color[1], color[2], 0.5);
    noStroke();
    fill(color[0], color[1], color[2]);
    float twinkle_size = size * random(0.6, 1.15);
    ellipse(x, y, twinkle_size, twinkle_size);
  }
};

class Asteroid {
  float position_x;
  float position_y;
  float size;
  float speed;
  int health;
  bool finished = false;
  bool isHit = false;

  Asteroid () {
    reset();
  }

  void reset() {
    size = random(60, 100);
    position_x = random(0, GAME_WIDTH);
    position_y = 0 - (size / 2);
    speed = random(1, 5) * DIFFICULTY / 5;
    health = floor(sqrt(size));
  }

  void hit(int damage) {
    health -= damage;
    isHit = true;
    if (health <= 0) {
      health = 0;
      player.addScore(ceil(size));
      finished = true;
    }
  }

  bool collidesWith(x, y) {
    float half_size = size / 2;
    
    xa1 = position_x - half_size;
    ya1 = position_y - half_size;
    xa2 = position_x + half_size;
    ya2 = position_y + half_size;

    if (x < xa1) return false;
    if (y < ya1) return false;
    if (x > xa2) return false;
    if (y > ya2) return false;

    return true;
  }

  void isFinished() {
    return finished;
  }

  void update() {
    position_y += speed;

    if (player.isMovingLeft()) {
      position_x += player.getSpeedY() * 0.5;
    } else if (player.isMovingRight()) {
      position_x -= player.getSpeedY() * 0.5;
    }

    if (position_y - (size / 2) > GAME_HEIGHT) {
      finished = true;
    }

    if (isHit) {
      stroke(255, 100, 100);
      fill(255, 0, 0);
      isHit = false;
    } else {
      stroke(255, 0, 0);
      fill(155, 0, 0);
    }

    ellipse(position_x, position_y, size, size);
  }
};