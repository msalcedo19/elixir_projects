defmodule DRJyE do
      def create_kernel do
        start_contest()
      end

      def comparar(match, num,pid) do
        if match == num do
            IO.puts "Gano! con la llamada #{num} al telefono#{inspect (pid)}"
            Process.exit(self(),:shutdown)
        else
            IO.puts "La llamada #{num} al telefono #{inspect (pid)} perdio, vuelva a intentar"
        end
      end

      def receive_call(match, num) do
        receive do
          {pid,:llamada} -> comparar(match,num,pid); receive_call(match, num + 1)
        end
      end

      def send_msg(padre) do
        receive do
            {:llamada} -> send padre, {self(), :llamada};
        end
        send_msg(padre)
      end


      #Genera llamadas y se las asigna a uno de los telefonos
      def generate_calls(pid1,pid2,pid3,pid4) do
        {_,var1} = Process.info(pid1, :message_queue_len)
        {_,var2} = Process.info(pid2, :message_queue_len)
        {_,var3} = Process.info(pid3, :message_queue_len)
        {_,var4} = Process.info(pid4, :message_queue_len)

        cond do
          Kernel.min(Kernel.min(var1,var2),Kernel.min(var3,var4)) == var1 -> send pid1, {:llamada}
          Kernel.min(Kernel.min(var1,var2),Kernel.min(var3,var4)) == var2 -> send pid2, {:llamada}
          Kernel.min(Kernel.min(var1,var2),Kernel.min(var3,var4)) == var3 -> send pid3, {:llamada}
          Kernel.min(Kernel.min(var1,var2),Kernel.min(var3,var4)) == var4 -> send pid4, {:llamada}
        end
        generate_calls(pid1,pid2,pid3,pid4)
      end

      def start_contest do
          random = Enum.random(10..60)
          IO.puts "-----------------------------------------------------------"
          IO.puts "Valor inicial: #{0}"
          IO.puts "Match inicial: #{random}"
          IO.puts "-----------------------------------------------------------"
          id=self()

          pid1 = spawn_link(fn -> send_msg(id) end)
          pid2 = spawn_link(fn -> send_msg(id) end)
          pid3 = spawn_link(fn -> send_msg(id) end)
          pid4 = spawn_link(fn -> send_msg(id) end)

          spawn_link(fn -> generate_calls(pid1,pid2,pid3,pid4) end)

          receive_call(random, 0)
      end
    end


