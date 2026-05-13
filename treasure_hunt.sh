#!/usr/bin/env bash

# ===== GAME STATE =====
health=100
gold=0
inventory=""

has_key=false
has_rope=false
has_lantern=false
has_map_piece=false
has_banana=false
has_feather=false
has_goblet=false
has_shell=false
has_crown=false
has_pearl=false

# ===== FUNCTIONS =====
pause() {
  echo
  read -p "Press Enter to continue..."
}

add_item() {
  item="$1"

  if [[ "$inventory" != *"$item"* ]]; then
    inventory="$inventory $item"
    echo "You got: $item"
  else
    echo "You already have: $item"
  fi
}

show_status() {
  echo
  echo "===== STATUS ====="
  echo "Health: $health"
  echo "Gold: $gold"
  echo "Inventory:$inventory"
  echo "=================="
}

type_text() {
  text="$1"
  delay="${2:-0.03}"

  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay"
  done

  printf "\n"
}

ask_riddle() {
  attempts=0

  echo
  echo "Riddle:"
  echo "I have keys but no locks,"
  echo "space but no room,"
  echo "you can enter but not go outside."

  while true; do
    echo
    echo "What do you do?"
    echo "1) Answer the riddle"
    echo "2) Want a hint"
    echo "3) Give up"
    echo

    read -p "Choose: " riddle_choice

    case "$riddle_choice" in
      1)
        read -p "Your answer: " answer
        ans=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

        if [[ "$ans" == "keyboard" ]]; then
          echo "The parrot squawks happily!"
          return 0
        else
          echo "Wrong answer."
          ((attempts++))
        fi
        ;;

      2)
        echo
        if [[ $attempts -eq 0 ]]; then
          echo "Hint: You are probably using one right now..."
        elif [[ $attempts -eq 1 ]]; then
          echo "Hint: It has keys, but not the kind that open doors."
        else
          echo "Final hint: It lets you 'enter' things."
        fi
        ;;

      3)
        echo
        read -p "Reveal the answer? (y/n): " reveal

        if [[ "$reveal" == "y" ]]; then
          echo "The answer was: keyboard"
          return 1
        else
          echo "The parrot waits..."
        fi
        ;;

      *)
        echo "Invalid choice."
        ;;
    esac
  done
}

# ===== INTRO =====
clear
type_text "🏴‍☠️ TREASURE HUNT" 0.04
echo
type_text "You wake up on a sandy beach, waves gently lapping behind you...palm trees swaying in the cool breeze" 0.03
type_text "In your hand is a torn map...you are on a forgotten island, full of secrets." 0.03
type_text "At its center: a red X... and a drawing of a stone tower." 0.03
pause

# ===== GAME LOOP =====
while true; do
  clear

  if [[ $health -le 0 ]]; then
    echo "You feel faint and collapse into darkness."
    echo "The island keeps its secrets forever."
    echo "GAME OVER"
    exit 0
  fi

  echo "Where do you go?"
  echo
  echo "1) Jungle"
  echo "2) Cliff"
  echo "3) Beach"
  echo "4) Cave"
  echo "5) Old Well"
  echo "6) Monkey Grove"
  echo "7) Stone Tower"
  echo "8) Mermaid Pool"
  echo "9) Check status"
  echo "10) Quit"
  echo

  read -p "Choose: " choice

  case "$choice" in

    1)
      clear
      echo "You step into the jungle."
      echo "A parrot peers at you."
      echo
      echo "The parrot presents a riddle..."

      if ask_riddle; then
        echo "It drops a rusty key."
        add_item "key"
        has_key=true
      else
        echo "The parrot seems disappointed, but lets you leave."
      fi

      pause
      ;;

    2)
      clear
      echo "You climb the cliff."

      if [[ "$has_map_piece" == false ]]; then
        echo "You find a torn piece of a map wedged in stone."
        add_item "map_piece"
        has_map_piece=true
      else
        echo "Nothing new here."
      fi

      pause
      ;;

    3)
      clear
      echo "You walk along the beach."

      r=$((RANDOM % 3))

      if [[ $r -eq 0 ]]; then
        echo "You find 10 gold."
        ((gold+=10))
      elif [[ $r -eq 1 ]]; then
        echo "A crab steals 5 gold. Rude little tax collector."
        ((gold-=5))
        if [[ $gold -lt 0 ]]; then
          gold=0
        fi
      else
        echo "You find a strange shell."
        add_item "shell"
        has_shell=true
      fi

      pause
      ;;

    4)
      clear
      echo "You enter the cave."

      if [[ "$has_key" == true && "$has_map_piece" == true && "$has_pearl" == true ]]; then
        echo "The key unlocks the chest."
        echo "The map reveals the hidden latch."
        echo "The pearl glows... the stone shifts."
        echo
        echo "The treasure rises from the ground."
        echo "YOU WIN 🏆"
        echo "Final Gold: $((gold + 500))"
        exit 0
      elif [[ "$has_key" == true ]]; then
        echo "You unlock the chest, but something is missing."
        echo "The chest has a pearl-shaped hollow in its lid."
      else
        echo "A locked chest sits in darkness."
        echo "You need a key."
      fi

      pause
      ;;

    5)
      clear
      echo "You find an old well."

      if [[ "$has_rope" == false ]]; then
        echo "You find a rope."
        add_item "rope"
        has_rope=true
      elif [[ "$has_lantern" == false ]]; then
        echo "You climb down using the rope."
        echo "It is dark... but you find a lantern."
        add_item "lantern"
        has_lantern=true
      else
        echo "The well is empty now."
      fi

      pause
      ;;

    6)
      clear
      echo "You enter the monkey grove."

      if [[ "$has_banana" == false ]]; then
        echo "You find a banana."
        add_item "banana"
        has_banana=true
      else
        echo "A monkey stares at your banana."
        read -p "Give it to the monkey? (y/n): " give

        if [[ "$give" == "y" ]]; then
          echo "The monkey gives you a golden feather."
          add_item "feather"
          has_feather=true
        else
          echo "The monkey angrily throws a coconut at you."
          ((health-=5))
        fi
      fi

      pause
      ;;

    7)
      clear
      echo "You stand before the Stone Tower."
      echo "A ghost knight blocks the door."

      if [[ "$has_feather" == true && "$has_lantern" == true ]]; then
        if [[ "$has_goblet" == false ]]; then
          echo "You present the golden feather and light the lantern."
          echo "The knight nods."
          echo "He gives you a royal goblet."
          add_item "goblet"
          has_goblet=true
        else
          echo "The knight has already given you his gift."
        fi
      else
        echo "The knight says:"
        echo "'Bring light... and something taken from mischief.'"
      fi

      pause
      ;;

    8)
      clear
      echo "You reach the Mermaid Pool."

      if [[ "$has_goblet" == true && "$has_shell" == true ]]; then
        echo "The shell hums. The goblet fills with moonlit water."

        if [[ "$has_crown" == false ]]; then
          echo "A mermaid rises and places a crown in your hands."
          add_item "crown"
          has_crown=true
        elif [[ "$has_pearl" == false ]]; then
          echo "The mermaid sees the crown and grants you a glowing pearl."
          add_item "pearl"
          has_pearl=true
        else
          echo "The pool is calm. The mermaid has no more gifts."
        fi
      else
        echo "The water is silent."
        echo "You sense it wants music and ceremony."
      fi

      pause
      ;;

    9)
      clear
      show_status
      pause
      ;;

    10)
      echo "You leave the island."
      echo "Maybe the real treasure was the bugs we fixed along the way."
      exit 0
      ;;

    *)
      echo "Invalid choice."
      pause
      ;;
  esac
done
