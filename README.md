
# Peace is Not an Option 🪿💥🦆

This is the official repository for the demo version of the Peace is Not an Option game, a top down survival shooter developed in the Godot Engine during the fifth edition of INATEL's game jam CODING, PIZZA & GLORY, where you are cybergoose fighting against the endless waves of psychoducks and their tyranny.

# Team

These are the amazing people that developed the game during the game jam through caffeine, sweat and tears (mostly caffeine):

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/GualterMM">
        <img src="https://avatars.githubusercontent.com/u/35864822?v=4" width="100px;" alt="Gualter's profile picture on GitHub"/><br>
        <sub>
          <b>Gualter Machado</b>
        </sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/IsabelaRezendeB">
        <img src="https://avatars.githubusercontent.com/u/49520751?v=4" width="100px;" alt="Isabela's profile picture on GitHub"/><br>
        <sub>
          <b>Isabela Rezende</b>
        </sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/drimmorais">
        <img src="https://avatars.githubusercontent.com/u/46358256?v=4" width="100px;" alt="Adrielle's profile picture on GitHub"/><br>
        <sub>
          <b>Adrielle Morais</b>
        </sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/henriemini">
        <img src="https://avatars.githubusercontent.com/u/61487012?v=4" width="100px;" alt="Henrique's profile picture on GitHub"/><br>
        <sub>
          <b>Henrique Iemini</b>
        </sub>
      </a>
    </td>
  </tr>
  <tr>
    <td>
        <ul>
            <li>Game concept and idealizer</li>
            <li>Game client programmer</li>
            <li>Game server programmer</li>
        </ul>
    </td>
    <td>
        <ul>
            <li>Game artist</li>
            <li>Digital splash art and icons</li>
            <li>3D assets and shader code</li>
        </ul>
    </td>
    <td>
        <ul>
            <li>Frontend sabotage platform developer</li>
            <li>RESTful API integration</li>
            <li>Mobile platforms compatibility</li>
        </ul>
    </td>
    <td>
        <ul>
            <li>Game design and QA</li>
            <li>Map designer</li>
            <li>Game balance</li>
        </ul>
    </td>
  </tr>
</table>

# Description
## The Goose (player)
You, as a cybernetically enhanced cybergoose, must survive the endless waves of psychoducks that want you dead. 

You have three weapons at your disposal: a pistol, a shotgun and an assault rifle; while the enemies have pistols, shotguns, sniper and their bare hands (or wings?). Killing enemy psychoducks grants you points. You have infinite ammo, but limited capacity in each weapon. Reload away!

You must survive for three minutes while getting as many points as possible.

Here's the kicker: when you start the game, you game session is exposed on the internet. Any person that connects to your game can **sabotage you**.

## The Ducks (sabouters)
Whenever a game is started, an online session is made available on the sabotage platform. You and other people can join the session either by scanning the QR code of that session or clicking on it.

From that point on, you can see how much time has elapsed since the Goose started the game, and if they have sabotage protection on. You, as the master hacker psychoduck that you are, can send sabotages to the Goose, which are applied immediately after the sabotage protection period has worn off.

There are a few sabotage options to choose from, each more diabolical than the next, and your objective is to sabotage the Goose until they lose.

All sabotages that aren't applied immediately are sent to the sabotage queue. The more time the Goose survives, the more sabotages can be applied simultaneously. However, each psychoduck hacker can only send one sabotage, so you must coordinate with more psychoduck hackers to send multiple simultaneous sabotages!

## Controls
* `W/A/S/D` or `Arrow Keys` for movement (controller support and rebinding is planned!)
* `Mouse` to move aiming reticle, `Left Mouse Button` to shoot
* `R` to reload

# Roadmap
The game in this repository is the demo version of the fully fledged game; as such, this roadmap contains information pertaining only to the future features **of the demo**:
* Modular weapons, for ease of development and modding of new weapons.
* Modular enemies, same reason as above.
* Sound (yup, no sound so far).
* Better 3D models and animation for entities.
* Improved UI elements (no stock Godot panels).
* Actual props in the map, instead of just walls.
* Improved water shader.
* Improved skybox.
* Improved enemy spawn point placement.
* Health and Ammo pickups.
* Limited weapon ammo.
* Sabotages in-effect reward the Goose with a point multiplier.
* Killstreak implementation, with point multiplier for high killstreaks.
* Dedicated melee button for the Goose (a loud, cybernetically enhanced HONK).
* Better enemy spawner algorithm, based on time, points, player location and a bunch of other states.
* Show name and a message from the saboteur. Get mocked by your friends in-game!
* An actual aiming reticle that shows accuracy, bloom and reloading icon.
* Dedicated dodge button to the Goose (dive underneath your enemies, or heck, fly above them!).
* Controller support.
* Settings page for game options and control rebinding.
* Leaderboards in-game.
* Boss enemies, triggered through sabotages or high points.
* Environmental dangers, both static (explosive barrels) and triggered by sabotages (turrets).
* Invincibility frames when taking damage.
* Display enemy HP when your hurt them.
* Power-ups/buffs that spawn in the map.
* Time extensions that spawn in the map and can be used to make more points.
* Upgrade station for weapons, for tuning weapons up to a maximum amount per game session.
* Saboteur statistics in the Leaderboards.
* More sabotages, because why not!
* Further gamification of the sabotage-side of things, like joint and coordinated sabotage between players, sabotage costs, and sabotage modifiers.

# Hosting your own sabotage platform

The demo version of the game, as well as the server and sabotage platform, are distributed as is; therefore, we don't have an official website that hosts the sabotaging platform (these things cost money, you know). Due to this, **we strongly encourage you** to host your own platform. Whether that's for LAN or WAN is up to you.

These are the official repositories containing each component that needs to be hosted. They should contain instructions for hosting them, but if they don't, give me some time to update them :D

* **Sabotage Server**: https://github.com/GualterMM/PINAO-backend

* **Sabotage Platform**: https://github.com/drimmorais/ID-frontend

